import { NextRequest, NextResponse } from 'next/server';
import { getAllBookings, updateBookingStatus, deleteBooking } from '@/lib/bookings';

// Simple admin password — change this or use env variable
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'haishang2026';

function checkAuth(req: NextRequest): boolean {
  const auth = req.headers.get('authorization');
  if (!auth) return false;
  const token = auth.replace('Bearer ', '');
  return token === ADMIN_PASSWORD;
}

// GET: fetch all bookings
export async function GET(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const bookings = await getAllBookings();
  return NextResponse.json({ bookings });
}

// PATCH: update booking status
export async function PATCH(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const { bookingId, status } = await req.json();
  if (!bookingId || !['pending', 'confirmed', 'cancelled'].includes(status)) {
    return NextResponse.json({ error: 'Invalid request' }, { status: 400 });
  }
  const updated = await updateBookingStatus(bookingId, status);
  if (!updated) {
    return NextResponse.json({ error: 'Booking not found' }, { status: 404 });
  }
  return NextResponse.json({ success: true });
}

// DELETE: remove booking
export async function DELETE(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  const { bookingId } = await req.json();
  if (!bookingId) {
    return NextResponse.json({ error: 'Missing bookingId' }, { status: 400 });
  }
  const deleted = await deleteBooking(bookingId);
  if (!deleted) {
    return NextResponse.json({ error: 'Booking not found' }, { status: 404 });
  }
  return NextResponse.json({ success: true });
}
