import { sql } from '@vercel/postgres';
import { ensureDb } from './db';

export interface BookkeepingEntry {
  id: string;
  createdAt: string;
  date: string;
  type: 'income' | 'expense';
  category: string;
  amount: number;
  description: string;
  paymentMethod?: string;
  reference?: string;
  notes?: string;
}

export const INCOME_CATEGORIES = [
  'Charter Revenue',
  'Shared Trip Revenue',
  'Tips',
  'Merchandise',
  'Other Income',
];

export const EXPENSE_CATEGORIES = [
  'Fuel',
  'Boat Maintenance',
  'Dock Fees',
  'Insurance',
  'Fishing Gear',
  'Bait & Tackle',
  'License & Permits',
  'Marketing',
  'Staff Wages',
  'Food & Beverages',
  'Office & Admin',
  'Other Expense',
];

export interface CreateEntryInput {
  date: string;
  type: 'income' | 'expense';
  category: string;
  amount: number;
  description: string;
  paymentMethod?: string;
  reference?: string;
  notes?: string;
}

export async function getAllEntries(): Promise<BookkeepingEntry[]> {
  await ensureDb();
  const result = await sql`SELECT * FROM bookkeeping ORDER BY date DESC, created_at DESC`;
  return result.rows.map(row => ({
    id: row.id,
    createdAt: row.created_at,
    date: row.date,
    type: row.type,
    category: row.category,
    amount: Number(row.amount),
    description: row.description,
    paymentMethod: row.payment_method,
    reference: row.reference,
    notes: row.notes,
  }));
}

export async function createEntry(input: CreateEntryInput): Promise<BookkeepingEntry> {
  await ensureDb();
  const id = `bk_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;

  await sql`
    INSERT INTO bookkeeping (id, date, type, category, amount, description, payment_method, reference, notes)
    VALUES (${id}, ${input.date}, ${input.type}, ${input.category}, ${input.amount}, ${input.description}, ${input.paymentMethod || null}, ${input.reference || null}, ${input.notes || null})
  `;

  return {
    id,
    createdAt: new Date().toISOString(),
    date: input.date,
    type: input.type,
    category: input.category,
    amount: input.amount,
    description: input.description,
    paymentMethod: input.paymentMethod,
    reference: input.reference,
    notes: input.notes,
  };
}

export async function deleteEntry(id: string): Promise<boolean> {
  await ensureDb();
  const result = await sql`DELETE FROM bookkeeping WHERE id = ${id}`;
  return (result.rowCount ?? 0) > 0;
}

export interface MonthlySummary {
  month: string;
  totalIncome: number;
  totalExpense: number;
  net: number;
  byCategory: { category: string; amount: number }[];
}

export async function getMonthlySummary(year: number, month: number): Promise<MonthlySummary> {
  await ensureDb();
  const monthStr = `${year}-${String(month).padStart(2, '0')}`;
  
  const result = await sql`
    SELECT type, category, SUM(amount) as total
    FROM bookkeeping
    WHERE date LIKE ${`${monthStr}%`}
    GROUP BY type, category
    ORDER BY type, category
  `;

  let totalIncome = 0;
  let totalExpense = 0;
  const byCategory: { category: string; amount: number }[] = [];

  for (const row of result.rows) {
    const amount = Number(row.total);
    if (row.type === 'income') {
      totalIncome += amount;
    } else {
      totalExpense += amount;
    }
    byCategory.push({ category: `${row.type === 'income' ? '📈' : '📉'} ${row.category}`, amount });
  }

  return {
    month: monthStr,
    totalIncome,
    totalExpense,
    net: totalIncome - totalExpense,
    byCategory,
  };
}
