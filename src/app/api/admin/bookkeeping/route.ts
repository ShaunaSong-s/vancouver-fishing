import { NextRequest, NextResponse } from 'next/server';
import { getAllEntries, createEntry, deleteEntry, getMonthlySummary } from '@/lib/bookkeeping';

const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'haishang2026';

function checkAuth(req: NextRequest): boolean {
  const auth = req.headers.get('authorization');
  if (!auth) return false;
  return auth.replace('Bearer ', '') === ADMIN_PASSWORD;
}

// GET: fetch all entries or monthly summary
export async function GET(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { searchParams } = new URL(req.url);
  const year = searchParams.get('year');
  const month = searchParams.get('month');

  if (year && month) {
    const summary = await getMonthlySummary(Number(year), Number(month));
    return NextResponse.json({ summary });
  }

  const entries = await getAllEntries();
  return NextResponse.json({ entries });
}

// POST: create new entry
export async function POST(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const body = await req.json();
  const { date, type, category, amount, description, paymentMethod, reference, receiptUrl, notes } = body;

  if (!date || !type || !category || !amount || !description) {
    return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
  }

  const entry = await createEntry({ date, type, category, amount: Number(amount), description, paymentMethod, reference, receiptUrl, notes });
  return NextResponse.json({ entry }, { status: 201 });
}

// DELETE: delete entry
export async function DELETE(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const { id } = await req.json();
  const deleted = await deleteEntry(id);
  if (!deleted) {
    return NextResponse.json({ error: 'Entry not found' }, { status: 404 });
  }
  return NextResponse.json({ success: true });
}
