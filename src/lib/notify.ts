import nodemailer from 'nodemailer';
import { Booking } from './bookings';

const ADMIN_EMAIL = process.env.ADMIN_EMAIL || 'info@topfishingcharter.ca';

function buildText(booking: Booking): string {
  const boat = booking.boatId === 'kingfisher' ? 'Kingfisher 3025' : 'Axopar 37';
  const type = booking.bookingType === 'charter' ? '包船 Charter' : '拼船 Shared';
  return `🎣 新预定 #${booking.bookingId}
姓名: ${booking.name}
电话: ${booking.phone}
邮箱: ${booking.email}
微信: ${booking.wechat || '-'}
船只: ${boat}
类型: ${type}
日期: ${booking.date}
人数: ${booking.passengers}
总价: $${booking.totalPrice} CAD
定金: $${booking.deposit} CAD
支付: ${booking.paymentMethod === 'wechat' ? '微信支付' : 'E-Transfer'}
备注: ${booking.notes || '-'}`;
}

function buildHtml(booking: Booking): string {
  const boat = booking.boatId === 'kingfisher' ? 'Kingfisher 3025 XRS (30ft)' : 'Axopar 37 XC (37ft)';
  const type = booking.bookingType === 'charter' ? '包船 Charter' : '拼船 Shared';
  const row = (label: string, val: string, bold = false) =>
    `<tr><td style="padding:8px 0;color:#888;width:80px">${label}</td><td style="padding:8px 0;${bold ? 'font-weight:700;' : ''}">${val}</td></tr>`;

  return `<!DOCTYPE html><html><head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,sans-serif;background:#0d1f3c;padding:20px">
<div style="max-width:580px;margin:0 auto;background:#0a1628;border-radius:12px;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,.3);border:1px solid rgba(223,192,138,0.15)">
  <div style="background:linear-gradient(135deg,#0a1628,#0d1f3c);color:#fff;padding:24px;text-align:center;border-bottom:1px solid rgba(223,192,138,0.2)">
    <h1 style="margin:0;font-size:20px;color:#dfc08a">🎣 新预定通知</h1>
    <p style="margin:6px 0 0;opacity:.75;font-size:13px">New Booking — ${booking.bookingId}</p>
  </div>
  <div style="padding:24px">
    <table style="width:100%;border-collapse:collapse;font-size:14px">
      ${row('姓名', booking.name, true)}
      ${row('电话', `<a href="tel:${booking.phone}" style="color:#dfc08a">${booking.phone}</a>`)}
      ${row('邮箱', `<a href="mailto:${booking.email}" style="color:#dfc08a">${booking.email}</a>`)}
      ${row('微信', booking.wechat || 'N/A')}
      <tr><td colspan="2" style="border-top:1px solid #eee;padding:4px 0"></td></tr>
      ${row('船只', boat, true)}
      ${row('类型', type)}
      ${row('日期', booking.date, true)}
      ${row('人数', `${booking.passengers} 人`)}
      <tr><td colspan="2" style="border-top:1px solid #eee;padding:4px 0"></td></tr>
      ${row('总价', `<span style="font-size:18px;color:#dfc08a;font-weight:800">$${booking.totalPrice.toLocaleString()} CAD</span>`)}
      ${row('定金', `<span style="color:#f75f3b;font-weight:700">$${booking.deposit.toLocaleString()} CAD</span>`)}
      ${row('支付', booking.paymentMethod === 'wechat' ? '微信支付 WeChat Pay' : 'E-Transfer')}
      ${booking.notes ? row('备注', booking.notes) : ''}
    </table>
  </div>
  <div style="background:rgba(255,255,255,0.03);padding:14px 24px;text-align:center;font-size:12px;color:rgba(255,255,255,0.4);border-top:1px solid rgba(223,192,138,0.1)">
    Top Vancouver Fishing Charter · 温哥华海尚海钓
  </div>
</div></body></html>`;
}

// ── Email via SMTP ──
async function sendEmail(booking: Booking): Promise<void> {
  const host = process.env.SMTP_HOST;
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;
  if (!host || !user || !pass) {
    console.warn('⚠️ SMTP not configured — skipping email notification');
    return;
  }
  const transporter = nodemailer.createTransport({
    host,
    port: Number(process.env.SMTP_PORT) || 465,
    secure: Number(process.env.SMTP_PORT) === 587 ? false : true,
    auth: { user, pass },
  });
  await transporter.sendMail({
    from: `"海尚海钓 Top Fishing" <${user}>`,
    to: ADMIN_EMAIL,
    subject: `🎣 新预定 ${booking.bookingId} — ${booking.name} ${booking.date}`,
    text: buildText(booking),
    html: buildHtml(booking),
  });
  console.log(`✅ Email sent to ${ADMIN_EMAIL}`);
}

// ── Telegram Bot (free, instant push to your phone) ──
async function sendTelegram(booking: Booking): Promise<void> {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  const chatId = process.env.TELEGRAM_CHAT_ID;
  if (!token || !chatId) {
    console.warn('⚠️ Telegram not configured — skipping Telegram notification');
    return;
  }
  const text = buildText(booking);
  const url = `https://api.telegram.org/bot${token}/sendMessage`;
  await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ chat_id: chatId, text, parse_mode: 'HTML' }),
  });
  console.log(`✅ Telegram notification sent`);
}

// ── Main: send all configured channels ──
export async function notifyAdmin(booking: Booking): Promise<void> {
  const results = await Promise.allSettled([
    sendEmail(booking),
    sendTelegram(booking),
  ]);

  // Log but don't crash on notification failure
  for (const r of results) {
    if (r.status === 'rejected') {
      console.error('❌ Notification error:', r.reason);
    }
  }

  // Always log to console as fallback
  console.log(`\n📋 Booking ${booking.bookingId}: ${booking.name} | ${booking.date} | $${booking.totalPrice}\n`);
}
