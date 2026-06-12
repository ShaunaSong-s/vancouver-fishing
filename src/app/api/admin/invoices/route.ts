import { NextRequest, NextResponse } from 'next/server';
import { getAllInvoices, createInvoice, updateInvoiceStatus, deleteInvoice } from '@/lib/invoices';

const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'haishang2026';

function checkAuth(req: NextRequest): boolean {
  const auth = req.headers.get('authorization');
  if (!auth) return false;
  return auth.replace('Bearer ', '') === ADMIN_PASSWORD;
}

// GET: fetch all invoices
export async function GET(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const invoices = await getAllInvoices();
  return NextResponse.json({ invoices });
}

// POST: create new invoice
export async function POST(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const body = await req.json();
  const { customerName, customerEmail, customerPhone, description, amount, date, notes } = body;

  if (!customerName || !description || !amount || !date) {
    return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
  }

  const invoice = await createInvoice({
    customerName,
    customerEmail,
    customerPhone,
    description,
    amount: Number(amount),
    date,
    notes,
  });

  return NextResponse.json({ invoice }, { status: 201 });
}

// PATCH: update invoice status
export async function PATCH(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const { id, status } = await req.json();
  if (!id || !['draft', 'sent', 'paid', 'cancelled'].includes(status)) {
    return NextResponse.json({ error: 'Invalid request' }, { status: 400 });
  }
  const invoice = await updateInvoiceStatus(id, status);
  if (!invoice) {
    return NextResponse.json({ error: 'Invoice not found' }, { status: 404 });
  }
  return NextResponse.json({ invoice });
}

// DELETE: delete invoice
export async function DELETE(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const { id } = await req.json();
  const deleted = await deleteInvoice(id);
  if (!deleted) {
    return NextResponse.json({ error: 'Invoice not found' }, { status: 404 });
  }
  return NextResponse.json({ success: true });
}
