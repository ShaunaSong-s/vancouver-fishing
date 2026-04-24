import { promises as fs } from 'fs';
import path from 'path';

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

const DATA_DIR = path.join(process.cwd(), 'data');
const BOOKINGS_FILE = path.join(DATA_DIR, 'bookings.json');

async function ensureDataDir() {
  try {
    await fs.access(DATA_DIR);
  } catch {
    await fs.mkdir(DATA_DIR, { recursive: true });
  }
}

async function readBookings(): Promise<Booking[]> {
  await ensureDataDir();
  try {
    const data = await fs.readFile(BOOKINGS_FILE, 'utf-8');
    return JSON.parse(data);
  } catch {
    return [];
  }
}

async function writeBookings(bookings: Booking[]) {
  await ensureDataDir();
  await fs.writeFile(BOOKINGS_FILE, JSON.stringify(bookings, null, 2), 'utf-8');
}

export async function addBooking(booking: Booking): Promise<void> {
  const bookings = await readBookings();
  bookings.unshift(booking);
  await writeBookings(bookings);
}

export async function getAllBookings(): Promise<Booking[]> {
  return readBookings();
}

export async function updateBookingStatus(
  bookingId: string,
  status: Booking['status']
): Promise<boolean> {
  const bookings = await readBookings();
  const idx = bookings.findIndex(b => b.bookingId === bookingId);
  if (idx === -1) return false;
  bookings[idx].status = status;
  await writeBookings(bookings);
  return true;
}

export async function deleteBooking(bookingId: string): Promise<boolean> {
  const bookings = await readBookings();
  const filtered = bookings.filter(b => b.bookingId !== bookingId);
  if (filtered.length === bookings.length) return false;
  await writeBookings(filtered);
  return true;
}
