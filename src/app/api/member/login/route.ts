import { NextRequest, NextResponse } from 'next/server';
import { queryCloudDB } from '@/lib/wxcloud';

/**
 * POST /api/member/login
 * Login by phone number — check against mini-program's members collection
 */
export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { phone } = body;

    if (!phone || typeof phone !== 'string') {
      return NextResponse.json({ success: false, message: 'Phone number is required' }, { status: 400 });
    }

    // Sanitize phone — only allow digits, spaces, dashes, plus, parens
    const sanitizedPhone = phone.replace(/[^\d\s\-+()]/g, '').slice(0, 20);
    if (!sanitizedPhone) {
      return NextResponse.json({ success: false, message: 'Invalid phone number' }, { status: 400 });
    }

    const results = await queryCloudDB('members', `{phone:"${sanitizedPhone}"}`).catch(() => []);

    if (!Array.isArray(results) || results.length === 0) {
      return NextResponse.json({ success: false, message: 'not_found' });
    }

    const member = results[0] as {
      memberNo?: string;
      memberType?: string;
      name?: string;
      phone?: string;
      remainingTrips?: number;
      expiryDate?: string;
    };

    // Determine benefits
    const memberType = member.memberType || 'new';
    let benefits = '';
    if (memberType === 'prepaid') {
      benefits = `剩余 ${member.remainingTrips || 0} 次拼船`;
    } else if (memberType === 'annual') {
      benefits = `年卡有效期至 ${member.expiryDate || '—'}`;
    }

    return NextResponse.json({
      success: true,
      memberNo: member.memberNo,
      memberType,
      name: member.name,
      phone: member.phone,
      benefits,
    });
  } catch (error) {
    console.error('Member login error:', error);
    return NextResponse.json({ success: false, message: 'Login failed' }, { status: 500 });
  }
}
