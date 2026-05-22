import { NextRequest, NextResponse } from 'next/server';
import { queryCloudDB } from '@/lib/wxcloud';

/**
 * GET /api/member/bookings?phone=xxx
 * Fetch booking history for a member from the shared cloud DB
 */
export async function GET(req: NextRequest) {
  const phone = req.nextUrl.searchParams.get('phone');

  if (!phone) {
    return NextResponse.json({ success: false, message: 'Phone required' }, { status: 400 });
  }

  // Sanitize phone input
  const sanitizedPhone = phone.replace(/[^\d\s\-+()]/g, '').slice(0, 20);
  if (!sanitizedPhone) {
    return NextResponse.json({ success: false, message: 'Invalid phone' }, { status: 400 });
  }

  try {
    const results = await queryCloudDB('bookings', `{phone:"${sanitizedPhone}"}`);

    // Sort by date descending
    const bookings = (results as Array<Record<string, unknown>>)
      .sort((a, b) => {
        const dateA = (a.tripDate || a.date || a.createdAt || '') as string;
        const dateB = (b.tripDate || b.date || b.createdAt || '') as string;
        return dateB.localeCompare(dateA);
      })
      .map(b => ({
        bookingId: b.bookingId,
        boatName: b.boatName || (b.boatId === 'kingfisher' ? 'Kingfisher 3025' : 'Axopar 37 XC'),
        bookingType: b.bookingType,
        tripDate: b.tripDate || b.date,
        passengers: b.passengers,
        totalPrice: b.totalPrice,
        status: b.status,
        source: b.source || 'miniapp',
        createdAt: b.createdAt || b.createTime,
      }));

    return NextResponse.json({ success: true, bookings });
  } catch (error) {
    console.error('Member bookings error:', error);
    return NextResponse.json({ success: false, message: 'Failed to fetch bookings' }, { status: 500 });
  }
}
