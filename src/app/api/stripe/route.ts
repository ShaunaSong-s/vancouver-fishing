import { NextRequest, NextResponse } from 'next/server';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-04-10' as any,
});

export async function POST(req: NextRequest) {
  try {
    const { bookingId, deposit, boatName, date, customerEmail } = await req.json();

    if (!bookingId || !deposit || !boatName || !date) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
    }

    const origin = req.headers.get('origin') || 'http://localhost:3001';

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      customer_email: customerEmail || undefined,
      line_items: [
        {
          price_data: {
            currency: 'cad',
            product_data: {
              name: `Fishing Charter Deposit — ${boatName}`,
              description: `Booking ${bookingId} · ${date}`,
            },
            unit_amount: Math.round(deposit * 100), // cents
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: `${origin}?payment=success&booking=${bookingId}`,
      cancel_url: `${origin}?payment=cancelled&booking=${bookingId}`,
      metadata: {
        bookingId,
        date,
        boatName,
      },
    });

    return NextResponse.json({ url: session.url });
  } catch (err) {
    console.error('Stripe error:', err);
    return NextResponse.json(
      { error: 'Failed to create checkout session' },
      { status: 500 }
    );
  }
}
