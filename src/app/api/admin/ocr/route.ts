import { NextRequest, NextResponse } from 'next/server';
import { GoogleGenerativeAI } from '@google/generative-ai';

const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'haishang2026';
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';

function checkAuth(req: NextRequest): boolean {
  const auth = req.headers.get('authorization');
  if (!auth) return false;
  return auth.replace('Bearer ', '') === ADMIN_PASSWORD;
}

export async function POST(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  if (!GEMINI_API_KEY) {
    return NextResponse.json({ error: 'GEMINI_API_KEY not configured' }, { status: 500 });
  }

  const formData = await req.formData();
  const file = formData.get('file') as File | null;

  if (!file) {
    return NextResponse.json({ error: 'No file provided' }, { status: 400 });
  }

  // Convert file to base64
  const bytes = await file.arrayBuffer();
  const base64 = Buffer.from(bytes).toString('base64');
  const mimeType = file.type || 'image/jpeg';

  const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
  const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });

  const prompt = `Analyze this receipt/invoice image and extract the following information in JSON format:
{
  "date": "YYYY-MM-DD format, the transaction date",
  "amount": number (total amount paid, without currency symbol),
  "description": "brief description of what was purchased/paid for",
  "category": "one of: Fuel, Boat Maintenance, Dock Fees, Insurance, Fishing Gear, Bait & Tackle, License & Permits, Marketing, Staff Wages, Food & Beverages, Office & Admin, Other Expense, Charter Revenue, Shared Trip Revenue, Tips, Merchandise, Other Income",
  "paymentMethod": "payment method if visible (e.g., Cash, Credit Card, Debit, E-Transfer)",
  "merchant": "merchant/store name if visible"
}

Rules:
- Return ONLY valid JSON, no markdown or explanation
- If a field cannot be determined, use empty string "" for strings or 0 for amount
- For category, pick the closest match from the list
- Amount should be the final total (including tax if shown)`;

  try {
    const result = await model.generateContent([
      prompt,
      { inlineData: { data: base64, mimeType } },
    ]);

    const text = result.response.text().trim();
    // Parse JSON from response (handle possible markdown wrapping)
    const jsonStr = text.replace(/^```json?\n?/, '').replace(/\n?```$/, '');
    const parsed = JSON.parse(jsonStr);

    return NextResponse.json({ result: parsed });
  } catch (error) {
    console.error('OCR error:', error);
    return NextResponse.json({ error: 'Failed to analyze receipt' }, { status: 500 });
  }
}
