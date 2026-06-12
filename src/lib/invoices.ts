import { promises as fs } from 'fs';
import path from 'path';

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

const DATA_DIR = path.join(process.cwd(), 'data');
const INVOICES_FILE = path.join(DATA_DIR, 'invoices.json');

async function ensureDataDir() {
  try {
    await fs.access(DATA_DIR);
  } catch {
    await fs.mkdir(DATA_DIR, { recursive: true });
  }
}

async function readInvoices(): Promise<Invoice[]> {
  await ensureDataDir();
  try {
    const data = await fs.readFile(INVOICES_FILE, 'utf-8');
    return JSON.parse(data);
  } catch {
    return [];
  }
}

async function writeInvoices(invoices: Invoice[]): Promise<void> {
  await ensureDataDir();
  await fs.writeFile(INVOICES_FILE, JSON.stringify(invoices, null, 2));
}

function generateInvoiceNumber(invoices: Invoice[]): string {
  const year = new Date().getFullYear();
  const yearInvoices = invoices.filter(i => i.invoiceNumber.startsWith(`INV-${year}`));
  const seq = yearInvoices.length + 1;
  return `INV-${year}-${String(seq).padStart(4, '0')}`;
}

export async function getAllInvoices(): Promise<Invoice[]> {
  return readInvoices();
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
  const invoices = await readInvoices();
  const taxRate = 0.05;
  const taxAmount = Math.round(input.amount * taxRate * 100) / 100;
  const total = Math.round((input.amount + taxAmount) * 100) / 100;

  const invoice: Invoice = {
    id: `inv_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
    invoiceNumber: generateInvoiceNumber(invoices),
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

  invoices.push(invoice);
  await writeInvoices(invoices);
  return invoice;
}

export async function updateInvoiceStatus(id: string, status: Invoice['status']): Promise<Invoice | null> {
  const invoices = await readInvoices();
  const idx = invoices.findIndex(i => i.id === id);
  if (idx === -1) return null;
  invoices[idx].status = status;
  await writeInvoices(invoices);
  return invoices[idx];
}

export async function deleteInvoice(id: string): Promise<boolean> {
  const invoices = await readInvoices();
  const filtered = invoices.filter(i => i.id !== id);
  if (filtered.length === invoices.length) return false;
  await writeInvoices(filtered);
  return true;
}
