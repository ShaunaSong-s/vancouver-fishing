"""SQLite database service for invoice persistence."""

import sqlite3
from datetime import datetime
from pathlib import Path
from typing import List, Optional

from app.models.invoice import (
    CustomerInfo,
    Invoice,
    InvoiceCreate,
    InvoiceStatus,
)

DB_PATH = Path(__file__).parent.parent.parent / "data" / "invoices.db"


def _get_db() -> sqlite3.Connection:
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL")
    return conn


def init_db():
    """Create invoice table if not exists."""
    conn = _get_db()
    conn.execute("""
        CREATE TABLE IF NOT EXISTS invoices (
            id TEXT PRIMARY KEY,
            invoice_number TEXT UNIQUE NOT NULL,
            created_at TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'draft',
            customer_name TEXT NOT NULL,
            customer_email TEXT,
            customer_phone TEXT,
            description TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            tax_rate REAL NOT NULL DEFAULT 0.05,
            tax_amount REAL NOT NULL,
            total REAL NOT NULL,
            notes TEXT,
            pdf_path TEXT
        )
    """)
    conn.commit()
    conn.close()


def _next_invoice_number(conn: sqlite3.Connection) -> str:
    """Generate next invoice number like INV-2026-0001."""
    year = datetime.now().year
    row = conn.execute(
        "SELECT COUNT(*) as cnt FROM invoices WHERE invoice_number LIKE ?",
        (f"INV-{year}-%",),
    ).fetchone()
    seq = (row["cnt"] or 0) + 1
    return f"INV-{year}-{seq:04d}"


def create_invoice(data: InvoiceCreate) -> Invoice:
    """Create and store a new invoice."""
    import uuid

    conn = _get_db()
    invoice_id = str(uuid.uuid4())
    invoice_number = _next_invoice_number(conn)
    now = datetime.utcnow()

    tax_amount = round(data.amount * data.tax_rate, 2)
    total = round(data.amount + tax_amount, 2)

    conn.execute(
        """INSERT INTO invoices (
            id, invoice_number, created_at, status,
            customer_name, customer_email, customer_phone,
            description, amount, date, tax_rate, tax_amount, total,
            notes
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        (
            invoice_id,
            invoice_number,
            now.isoformat(),
            InvoiceStatus.DRAFT.value,
            data.customer.name,
            data.customer.email,
            data.customer.phone,
            data.description,
            data.amount,
            data.date.isoformat(),
            data.tax_rate,
            tax_amount,
            total,
            data.notes,
        ),
    )
    conn.commit()
    conn.close()

    return Invoice(
        id=invoice_id,
        invoice_number=invoice_number,
        created_at=now,
        status=InvoiceStatus.DRAFT,
        customer=data.customer,
        description=data.description,
        amount=data.amount,
        date=data.date,
        tax_rate=data.tax_rate,
        tax_amount=tax_amount,
        total=total,
        notes=data.notes,
    )


def _row_to_invoice(row: sqlite3.Row) -> Invoice:
    return Invoice(
        id=row["id"],
        invoice_number=row["invoice_number"],
        created_at=datetime.fromisoformat(row["created_at"]),
        status=InvoiceStatus(row["status"]),
        customer=CustomerInfo(
            name=row["customer_name"],
            email=row["customer_email"],
            phone=row["customer_phone"],
        ),
        description=row["description"],
        amount=row["amount"],
        date=row["date"],
        tax_rate=row["tax_rate"],
        tax_amount=row["tax_amount"],
        total=row["total"],
        notes=row["notes"],
        pdf_path=row["pdf_path"],
    )


def get_invoice(invoice_id: str) -> Optional[Invoice]:
    conn = _get_db()
    row = conn.execute("SELECT * FROM invoices WHERE id = ?", (invoice_id,)).fetchone()
    conn.close()
    if not row:
        return None
    return _row_to_invoice(row)


def list_invoices(status: Optional[str] = None, limit: int = 50) -> List[Invoice]:
    conn = _get_db()
    if status:
        rows = conn.execute(
            "SELECT * FROM invoices WHERE status = ? ORDER BY created_at DESC LIMIT ?",
            (status, limit),
        ).fetchall()
    else:
        rows = conn.execute(
            "SELECT * FROM invoices ORDER BY created_at DESC LIMIT ?", (limit,)
        ).fetchall()
    conn.close()
    return [_row_to_invoice(row) for row in rows]


def update_invoice_status(invoice_id: str, status: InvoiceStatus) -> Optional[Invoice]:
    conn = _get_db()
    conn.execute(
        "UPDATE invoices SET status = ? WHERE id = ?", (status.value, invoice_id)
    )
    conn.commit()
    conn.close()
    return get_invoice(invoice_id)


def set_invoice_pdf_path(invoice_id: str, pdf_path: str):
    conn = _get_db()
    conn.execute("UPDATE invoices SET pdf_path = ? WHERE id = ?", (pdf_path, invoice_id))
    conn.commit()
    conn.close()


# Initialize DB on import
init_db()
