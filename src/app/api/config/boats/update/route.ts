import { NextRequest, NextResponse } from 'next/server';
import { queryCloudDB, addToCloudDB, updateCloudDB } from '@/lib/wxcloud';

const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || '';

/**
 * POST /api/config/boats/update
 * Admin-only: update boat pricing in cloud DB (syncs to both website and mini-program)
 */
export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { password, boats } = body;

    // Auth check
    if (!password || password !== ADMIN_PASSWORD) {
      return NextResponse.json({ success: false, message: 'Unauthorized' }, { status: 401 });
    }

    if (!Array.isArray(boats) || boats.length === 0) {
      return NextResponse.json({ success: false, message: 'Invalid boats data' }, { status: 400 });
    }

    // For each boat, upsert into boat_config collection
    for (const boat of boats) {
      if (!boat.id) continue;

      const existing = await queryCloudDB('boat_config', `{id:"${boat.id}"}`).catch(() => []);

      if (Array.isArray(existing) && existing.length > 0) {
        // Update existing
        const doc = existing[0] as { _id: string };
        await updateCloudDB('boat_config', doc._id, {
          ...boat,
          updateTime: new Date().toISOString(),
        });
      } else {
        // Create new
        await addToCloudDB('boat_config', {
          ...boat,
          createTime: new Date().toISOString(),
          updateTime: new Date().toISOString(),
        });
      }
    }

    return NextResponse.json({ success: true, message: `Updated ${boats.length} boats` });
  } catch (error) {
    console.error('Config update error:', error);
    return NextResponse.json({ success: false, message: 'Update failed' }, { status: 500 });
  }
}
