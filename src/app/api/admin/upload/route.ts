import { NextRequest, NextResponse } from 'next/server';
import { put } from '@vercel/blob';

const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'haishang2026';

function checkAuth(req: NextRequest): boolean {
  const auth = req.headers.get('authorization');
  if (!auth) return false;
  return auth.replace('Bearer ', '') === ADMIN_PASSWORD;
}

export async function POST(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const formData = await req.formData();
  const file = formData.get('file') as File | null;

  if (!file) {
    return NextResponse.json({ error: 'No file provided' }, { status: 400 });
  }

  // Generate unique filename
  const ext = file.name.split('.').pop() || 'jpg';
  const filename = `receipts/${Date.now()}-${Math.random().toString(36).slice(2, 8)}.${ext}`;

  const blob = await put(filename, file, {
    access: 'public',
  });

  return NextResponse.json({ url: blob.url });
}
