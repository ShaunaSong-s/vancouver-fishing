import { NextRequest, NextResponse } from 'next/server';
import { queryCloudDB } from '@/lib/wxcloud';

/**
 * GET /api/booking/availability?boatId=kingfisher&date=2026-06-15
 * Checks cloud DB for existing bookings on the given date/boat
 */
export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const boatId = searchParams.get('boatId');
    const date = searchParams.get('date');

    if (!boatId || !date) {
      return NextResponse.json({ error: 'boatId and date are required' }, { status: 400 });
    }

    // Validate boatId is one of our known boats
    const maxCapacity: Record<string, number> = { kingfisher: 8, axpor: 10, axopar: 10 };
    if (!maxCapacity[boatId]) {
      return NextResponse.json({ error: 'Invalid boatId' }, { status: 400 });
    }

    // Validate date format (YYYY-MM-DD)
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      return NextResponse.json({ error: 'Invalid date format' }, { status: 400 });
    }

    const capacity = maxCapacity[boatId];

    // Map boatId variants (website uses 'axpor', mini-program uses 'axopar')
    const boatIds = boatId === 'axpor' || boatId === 'axopar' ? ['axpor', 'axopar'] : [boatId];

    // Query cloud DB for bookings on this date/boat (get ALL, filter status in code)
    // Use db.command for OR query on boatId variants
    const where = boatIds.length > 1
      ? `{boatId:db.RegExp({regexp:"^(${boatIds.join('|')})$",options:"i"}),tripDate:"${date}"}`
      : `{boatId:"${boatId}",tripDate:"${date}"}`;

    let bookings: Array<{ bookingType?: string; passengers?: number; status?: string }> = [];
    try {
      bookings = await queryCloudDB('bookings', where) as Array<{ bookingType?: string; passengers?: number; status?: string }>;
      // Exclude cancelled bookings — count pending, confirmed, deposit_paid
      bookings = bookings.filter(b => b.status !== 'cancelled' && b.status !== 'refunded');
    } catch {
      // If cloud query fails, assume available
      return NextResponse.json({ available: true, remainingSpots: capacity, charterBlocked: false });
    }

    // Check if charter exists
    const hasCharter = bookings.some(b => b.bookingType === 'charter');
    if (hasCharter) {
      return NextResponse.json({ available: false, remainingSpots: 0, charterBlocked: true });
    }

    // Calculate remaining shared spots
    const bookedPassengers = bookings.reduce((sum, b) => sum + (b.passengers || 1), 0);
    const remainingSpots = capacity - bookedPassengers;

    return NextResponse.json({
      available: remainingSpots > 0,
      remainingSpots: Math.max(0, remainingSpots),
      charterBlocked: false,
      totalBooked: bookedPassengers,
    });
  } catch (error) {
    console.error('Availability check error:', error);
    return NextResponse.json({ available: true, remainingSpots: 8 });
  }
}
