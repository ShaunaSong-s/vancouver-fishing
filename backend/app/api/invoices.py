"""Admin API endpoints for invoice management."""

from typing import Optional, List

from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse

from app.models.invoice import Invoice, InvoiceCreate, InvoiceStatus
from app.services.invoice_db import (
    create_invoice,
    get_invoice,
    list_invoices,
    set_invoice_pdf_path,
    update_invoice_status,
)
from app.services.invoice_pdf import generate_invoice_pdf

router = APIRouter()


@router.post("/invoices", response_model=Invoice)
async def create_new_invoice(data: InvoiceCreate):
    """Create a new fishing charter invoice."""
    invoice = create_invoice(data)
    return invoice


@router.get("/invoices", response_model=List[Invoice])
async def get_invoices(status: Optional[str] = None, limit: int = 50):
    """List invoices, optionally filtered by status."""
    return list_invoices(status=status, limit=limit)


@router.get("/invoices/{invoice_id}", response_model=Invoice)
async def get_invoice_by_id(invoice_id: str):
    """Get a single invoice by ID."""
    invoice = get_invoice(invoice_id)
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
    return invoice


@router.patch("/invoices/{invoice_id}/status")
async def change_invoice_status(invoice_id: str, status: InvoiceStatus):
    """Update invoice status (draft, sent, paid, cancelled)."""
    invoice = update_invoice_status(invoice_id, status)
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
    return invoice


@router.post("/invoices/{invoice_id}/pdf")
async def generate_pdf(invoice_id: str):
    """Generate PDF for an invoice and return download link."""
    invoice = get_invoice(invoice_id)
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")

    pdf_path = generate_invoice_pdf(invoice)
    set_invoice_pdf_path(invoice_id, pdf_path)

    return {
        "status": "success",
        "invoice_number": invoice.invoice_number,
        "download_url": f"/api/v1/admin/invoices/{invoice_id}/download",
    }


@router.get("/invoices/{invoice_id}/download")
async def download_invoice_pdf(invoice_id: str):
    """Download the generated PDF invoice."""
    invoice = get_invoice(invoice_id)
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found")
    if not invoice.pdf_path:
        raise HTTPException(status_code=404, detail="PDF not generated yet. Call POST /pdf first.")

    return FileResponse(
        invoice.pdf_path,
        media_type="application/pdf",
        filename=f"{invoice.invoice_number}.pdf",
    )
