import { NextRequest, NextResponse } from 'next/server';
import { addToCloudDB, queryCloudDB } from '@/lib/wxcloud';

/**
 * POST /api/member/register
 * Register a new member from the website — syncs with mini-program's members collection
 */
export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { name, phone, email, wechat } = body;

    if (!name || !phone || typeof name !== 'string' || typeof phone !== 'string') {
      return NextResponse.json({ success: false, message: 'Name and phone are required' }, { status: 400 });
    }

    // Sanitize inputs to prevent injection in cloud DB queries
    const sanitizedPhone = phone.replace(/[^\d\s\-+()]/g, '').slice(0, 20);
    const sanitizedName = name.replace(/["{}\\]/g, '').slice(0, 50);
    if (!sanitizedPhone || !sanitizedName) {
      return NextResponse.json({ success: false, message: 'Invalid input' }, { status: 400 });
    }

    // Check if phone already registered
    const existing = await queryCloudDB('members', `{phone:"${sanitizedPhone}"}`).catch(() => []);
    if (Array.isArray(existing) && existing.length > 0) {
      const member = existing[0] as { memberNo?: string; memberType?: string; name?: string };
      return NextResponse.json({
        success: true,
        isExisting: true,
        memberNo: member.memberNo,
        memberType: member.memberType || 'new',
        name: member.name,
        message: 'Already registered',
      });
    }

    // Generate memberNo — query count and increment
    let count = 0;
    try {
      const allMembers = await queryCloudDB('members', '{}');
      count = Array.isArray(allMembers) ? allMembers.length : 0;
    } catch {
      count = Math.floor(Math.random() * 1000);
    }
    const memberNo = String(10100 + count + 1);

    // Write to cloud DB (same collection as mini-program)
    await addToCloudDB('members', {
      memberNo,
      name: sanitizedName,
      phone: sanitizedPhone,
      email: email || '',
      wechatId: wechat || '',
      memberType: 'new',
      source: 'website',
      openid: '',  // website users don't have WeChat openid
      createTime: new Date().toISOString(),
      updateTime: new Date().toISOString(),
    });

    return NextResponse.json({
      success: true,
      isExisting: false,
      memberNo,
      memberType: 'new',
      name: sanitizedName,
      message: 'Registration successful',
    });
  } catch (error) {
    console.error('Member register error:', error);
    return NextResponse.json({ success: false, message: 'Registration failed' }, { status: 500 });
  }
}
