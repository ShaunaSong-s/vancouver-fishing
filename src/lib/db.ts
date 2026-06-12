import { sql } from '@vercel/postgres';

export async function initDatabase() {
  await sql`
    CREATE TABLE IF NOT EXISTS invoices (
      id TEXT PRIMARY KEY,
      invoice_number TEXT UNIQUE NOT NULL,
      created_at TIMESTAMP DEFAULT NOW(),
      status TEXT DEFAULT 'draft',
      customer_name TEXT NOT NULL,
      customer_email TEXT,
      customer_phone TEXT,
      description TEXT NOT NULL,
      amount DECIMAL(10,2) NOT NULL,
      date TEXT NOT NULL,
      tax_rate DECIMAL(5,4) DEFAULT 0.05,
      tax_amount DECIMAL(10,2) NOT NULL,
      total DECIMAL(10,2) NOT NULL,
      notes TEXT
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS bookkeeping (
      id TEXT PRIMARY KEY,
      created_at TIMESTAMP DEFAULT NOW(),
      date TEXT NOT NULL,
      type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
      category TEXT NOT NULL,
      amount DECIMAL(10,2) NOT NULL,
      description TEXT NOT NULL,
      payment_method TEXT,
      reference TEXT,
      receipt_url TEXT,
      notes TEXT
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS bookings (
      booking_id TEXT PRIMARY KEY,
      boat_id TEXT,
      booking_type TEXT,
      date TEXT,
      passengers INTEGER,
      name TEXT NOT NULL,
      phone TEXT,
      email TEXT,
      wechat TEXT,
      payment_method TEXT,
      total_price DECIMAL(10,2),
      deposit DECIMAL(10,2),
      lang TEXT DEFAULT 'zh',
      notes TEXT,
      status TEXT DEFAULT 'pending',
      created_at TIMESTAMP DEFAULT NOW()
    )
  `;
}

// Initialize on first import
let initialized = false;
export async function ensureDb() {
  if (!initialized) {
    await initDatabase();
    initialized = true;
  }
}
