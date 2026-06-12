import { sql } from '@vercel/postgres';
import { ensureDb } from './db';

export interface Invoice {
  id: string;
  invoiceNumber: string;
  createdAt: string;
  status: 'draft' | 'sent' | 'paid' | 'cancelled';
  customerName: string;
  customerEmail?: string;
  customerPhone?: string;
  description: string;
  amount: number;
  date: string;
  taxRate: number;
  taxAmount: number;
  total: number;
  notes?: string;
}

async function generateInvoiceNumber(): Promise<string> {
  const year = new Date().getFullYear();
  const result = await sql`
    SELECT COUNT(*) as count FROM invoices 
    WHERE invoice_number LIKE ${`INV-${year}%`}
  `;
  const seq = Number(result.rows[0].count) + 1;
  return `INV-${year}-${String(seq).padStart(4, '0')}`;
}

export async function getAllInvoices(): Promise<Invoice[]> {
  await ensureDb();
  const result = await sql`SELECT * FROM invoices ORDER BY created_at DESC`;
  return result.rows.map(row => ({
    id: row.id,
    invoiceNumber: row.invoice_number,
    createdAt: row.created_at,
    status: row.status,
    customerName: row.customer_name,
    customerEmail: row.customer_email,
    customerPhone: row.customer_phone,
    description: row.description,
    amount: Number(row.amount),
    date: row.date,
    taxRate: Number(row.tax_rate),
    taxAmount: Number(row.tax_amount),
    total: Number(row.total),
    notes: row.notes,
  }));
}

export interface CreateInvoiceInput {
  customerName: string;
  customerEmail?: string;
  customerPhone?: string;
  description: string;
  amount: number;
  date: string;
  notes?: string;
}

export async function createInvoice(input: CreateInvoiceInput): Promise<Invoice> {
  await ensureDb();
  const taxRate = 0.05;
  const taxAmount = Math.round(input.amount * taxRate * 100) / 100;
  const total = Math.round((input.amount + taxAmount) * 100) / 100;
  const id = `inv_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
  const invoiceNumber = await generateInvoiceNumber();

  await sql`
    INSERT INTO invoices (id, invoice_number, status, customer_name, customer_email, customer_phone, description, amount, date, tax_rate, tax_amount, total, notes)
    VALUES (${id}, ${invoiceNumber}, 'draft', ${input.customerName}, ${input.customerEmail || null}, ${input.customerPhone || null}, ${input.description}, ${input.amount}, ${input.date}, ${taxRate}, ${taxAmount}, ${total}, ${input.notes || null})
  `;

  return {
    id,
    invoiceNumber,
    createdAt: new Date().toISOString(),
    status: 'draft',
    customerName: input.customerName,
    customerEmail: input.customerEmail,
    customerPhone: input.customerPhone,
    description: input.description,
    amount: input.amount,
    date: input.date,
    taxRate,
    taxAmount,
    total,
    notes: input.notes,
  };
}

export async function updateInvoiceStatus(id: string, status: Invoice['status']): Promise<Invoice | null> {
  await ensureDb();
  const result = await sql`
    UPDATE invoices SET status = ${status} WHERE id = ${id} RETURNING *
  `;
  if (result.rows.length === 0) return null;
  const row = result.rows[0];
  return {
    id: row.id,
    invoiceNumber: row.invoice_number,
    createdAt: row.created_at,
    status: row.status,
    customerName: row.customer_name,
    customerEmail: row.customer_email,
    customerPhone: row.customer_phone,
    description: row.description,
    amount: Number(row.amount),
    date: row.date,
    taxRate: Number(row.tax_rate),
    taxAmount: Number(row.tax_amount),
    total: Number(row.total),
    notes: row.notes,
  };
}

export async function deleteInvoice(id: string): Promise<boolean> {
  await ensureDb();
  const result = await sql`DELETE FROM invoices WHERE id = ${id}`;
  return (result.rowCount ?? 0) > 0;
}

