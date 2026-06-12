"""Invoice data models for fishing charter trip bookings."""

from datetime import date, datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class InvoiceStatus(str, Enum):
    DRAFT = "draft"
    SENT = "sent"
    PAID = "paid"
    CANCELLED = "cancelled"


class CustomerInfo(BaseModel):
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None


class InvoiceCreate(BaseModel):
    """Request body to create a new invoice."""
    customer: CustomerInfo
    description: str = "Fishing charter trip"
    amount: float
    date: date
    notes: Optional[str] = None
    tax_rate: float = Field(default=0.05, description="GST rate (5% in BC)")


class Invoice(BaseModel):
    """Full invoice record."""
    id: str
    invoice_number: str
    created_at: datetime
    status: InvoiceStatus = InvoiceStatus.DRAFT
    customer: CustomerInfo
    description: str
    amount: float
    date: date
    tax_rate: float
    tax_amount: float
    total: float
    notes: Optional[str] = None
    pdf_path: Optional[str] = None
