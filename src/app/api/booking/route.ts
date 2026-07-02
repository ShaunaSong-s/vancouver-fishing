import { NextRequest, NextResponse } from 'next/server';
import { BOATS } from '@/lib/types';
import { addBooking } from '@/lib/bookings';
import { notifyAdmin } from '@/lib/notify';
import { addToCloudDB } from '@/lib/wxcloud';

export async function POST(req: NextRequest) {
  // ── Booking system paused ──
  return NextResponse.json(
    { success: false, message: 'Booking is currently paused. Please contact us directly.' },
    { status: 503 }
  );

  try {
    const body = await req.json();
    const { boatId, bookingType, date, passengers, name, phone, email, wechat, paymentMethod, notes, lang } = body;

    // Validate required fields
    if (!boatId || !bookingType || !date || !passengers || !name || !phone || !email) {
      return NextResponse.json(
        { success: false, message: 'Missing required fields' },
        { status: 400 }
      );
    }

    // Validate boat
    const boat = BOATS[boatId];
    if (!boat) {
      return NextResponse.json(
        { success: false, message: 'Invalid boat selection' },
        { status: 400 }
      );
    }

    // Validate passengers
    const passengerCount = parseInt(passengers);
    if (passengerCount < 1 || passengerCount > boat.maxPassengers) {
      return NextResponse.json(
        { success: false, message: `Passengers must be between 1 and ${boat.maxPassengers}` },
        { status: 400 }
      );
    }

    // Validate date is in the future
    const bookingDate = new Date(date);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (bookingDate <= today) {
      return NextResponse.json(
        { success: false, message: 'Date must be in the future' },
        { status: 400 }
      );
    }

    // Calculate pricing
    const totalPrice = bookingType === 'charter' ? boat.charterPrice : boat.perPersonPrice * passengerCount;
    const deposit = bookingType === 'charter' ? 500 : 100 * passengerCount;

    // Generate booking ID
    const bookingId = `HS-${Date.now().toString(36).toUpperCase()}`;

    // Store booking
    const booking = {
      bookingId,
      boatId,
      bookingType,
      date,
      passengers: passengerCount,
      name,
      phone,
      email,
      wechat: wechat || '',
      paymentMethod,
      totalPrice,
      deposit,
      lang: lang || 'zh',
      notes: notes || '',
      status: 'pending' as const,
      createdAt: new Date().toISOString(),
    };

    await addBooking(booking);

    // Sync to WeChat mini-program cloud database
    try {
      const boatName = boatId === 'kingfisher' ? 'Kingfisher 3025' : 'Axopar 37';
      await addToCloudDB('bookings', {
        bookingId,
        boatId,
        boatName,
        bookingType,
        tripDate: date,
        passengers: passengerCount,
        name,
        phone,
        email,
        wechatId: wechat || '',
        wechatNote: '',
        paymentMethod,
        totalPrice,
        depositAmount: deposit,
        customerType: 'website',
        status: 'pending',
        notes: notes || '',
        source: 'website',
        createdAt: new Date().toISOString(),
        createTime: new Date().toISOString(),
        updateTime: new Date().toISOString(),
      });
      console.log(`[WxCloud] Booking ${bookingId} synced to mini-program`);
    } catch (wxErr) {
      // Don't fail the booking if cloud sync fails
      console.error('[WxCloud] Sync failed:', wxErr);
    }

    // Notify admin (email / console log)
    await notifyAdmin(booking);

    // SMS Confirmation (integrate with Twilio when ready)
    console.log(`[SMS] Would send confirmation to ${phone}: Booking ${bookingId}`);

    return NextResponse.json({
      success: true,
      bookingId,
      message: lang === 'zh'
        ? `预定成功！订单号：${bookingId}，我们会尽快通过短信确认。`
        : `Booking confirmed! ID: ${bookingId}. We'll confirm via SMS shortly.`,
      totalPrice,
      deposit,
    });
  } catch (error) {
    console.error('Booking error:', error);
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    );
  }
}
