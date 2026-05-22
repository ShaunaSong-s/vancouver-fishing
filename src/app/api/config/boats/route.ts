import { NextResponse } from 'next/server';
import { queryCloudDB } from '@/lib/wxcloud';

/**
 * GET /api/config/boats
 * Fetch boat pricing & schedule config from cloud DB (shared with mini-program)
 * Falls back to local defaults if cloud unavailable
 */

const LOCAL_DEFAULTS = [
  {
    id: 'kingfisher',
    name: 'Kingfisher 3025',
    length: '30',
    maxPassengers: 8,
    charterPrice: 1700,
    perPersonPrice: 240,
    deposit: 500,
    sharedDeposit: 100,
    image: '/images/kingfisher.jpg',
    active: true,
  },
  {
    id: 'axopar',
    name: 'Axopar 37 XC',
    length: '37',
    maxPassengers: 10,
    charterPrice: 2200,
    perPersonPrice: 240,
    deposit: 500,
    sharedDeposit: 100,
    image: '/images/axpor.jpg',
    active: true,
  },
];

export async function GET() {
  try {
    const results = await queryCloudDB('boat_config', '{}');
    const configs = results as Array<Record<string, unknown>>;

    if (configs.length > 0) {
      // Return cloud config, sorted by id
      const boats = configs
        .filter(c => c.active !== false)
        .map(c => ({
          id: c.id || c.boatId,
          name: c.name,
          length: c.length,
          maxPassengers: c.maxPassengers || c.guests,
          charterPrice: c.charterPrice,
          perPersonPrice: c.perPersonPrice || c.sharedPrice,
          deposit: c.deposit || 500,
          sharedDeposit: c.sharedDeposit || 100,
          image: c.image,
          active: c.active !== false,
        }));

      return NextResponse.json({ success: true, source: 'cloud', boats });
    }

    // Fallback to local defaults
    return NextResponse.json({ success: true, source: 'local', boats: LOCAL_DEFAULTS });
  } catch (error) {
    console.error('Config fetch error:', error);
    return NextResponse.json({ success: true, source: 'local', boats: LOCAL_DEFAULTS });
  }
}
