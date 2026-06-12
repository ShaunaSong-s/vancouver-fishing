import { sql } from '@vercel/postgres';
import { ensureDb } from './db';

export interface Booking {
  bookingId: string;
  boatId: string;
  bookingType: string;
  date: string;
  passengers: number;
  name: string;
  phone: string;
  email: string;
  wechat?: string;
  paymentMethod: string;
  totalPrice: number;
  deposit: number;
  lang: string;
  notes?: string;
  status: 'pending' | 'confirmed' | 'cancelled';
  createdAt: string;
}

function rowToBooking(row: Record<string, unknown>): Booking {
  return {
    bookingId: row.booking_id as string,
    boatId: row.boat_id as string,
    bookingType: row.booking_type as string,
    date: row.date as string,
    passengers: Number(row.passengers),
    name: row.name as string,
    phone: row.phone as string,
    email: row.email as string,
    wechat: row.wechat as string | undefined,
    paymentMethod: row.payment_method as string,
    totalPrice: Number(row.total_price),
    deposit: Number(row.deposit),
    lang: (row.lang as string) || 'zh',
    notes: row.notes as string | undefined,
    status: row.status as Booking['status'],
    createdAt: row.created_at as string,
  };
}

export async function addBooking(booking: Booking): Promise<void> {
  await ensureDb();
  await sql`
    INSERT INTO bookings (booking_id, boat_id, booking_type, date, passengers, name, phone, email, wechat, payment_method, total_price, deposit, lang, notes, status)
    VALUES (${booking.bookingId}, ${booking.boatId}, ${booking.bookingType}, ${booking.date}, ${booking.passengers}, ${booking.name}, ${booking.phone}, ${booking.email}, ${booking.wechat || null}, ${booking.paymentMethod}, ${booking.totalPrice}, ${booking.deposit}, ${booking.lang || 'zh'}, ${booking.notes || null}, ${booking.status || 'pending'})
  `;
}

export async function getAllBookings(): Promise<Booking[]> {
  await ensureDb();
  const result = await sql`SELECT * FROM bookings ORDER BY created_at DESC`;
  return result.rows.map(rowToBooking);
}

export async function updateBookingStatus(
  bookingId: string,
  status: Booking['status']
): Promise<boolean> {
  await ensureDb();
  const result = await sql`UPDATE bookings SET status = ${status} WHERE booking_id = ${bookingId}`;
  return (result.rowCount ?? 0) > 0;
}

export async function deleteBooking(bookingId: string): Promise<boolean> {
  await ensureDb();
  const result = await sql`DELETE FROM bookings WHERE booking_id = ${bookingId}`;
  return (result.rowCount ?? 0) > 0;
}

