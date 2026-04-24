'use client';

import { useLanguage } from '@/i18n/LanguageContext';
import { BOATS } from '@/lib/types';
import { useState, FormEvent } from 'react';

export default function BookingForm() {
  const { t, lang } = useLanguage();

  const [form, setForm] = useState({
    boatId: 'kingfisher' as 'kingfisher' | 'axpor',
    bookingType: 'charter' as 'charter' | 'shared',
    date: '',
    passengers: 1,
    name: '',
    phone: '',
    email: '',
    wechat: '',
    paymentMethod: 'credit_card' as 'wechat' | 'credit_card' | 'e_transfer',
    notes: '',
  });

  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState<{ success: boolean; message: string; bookingId?: string; paymentMethod?: string } | null>(null);

  const boat = BOATS[form.boatId];
  const maxPassengers = boat.maxPassengers;
  const totalPrice = form.bookingType === 'charter' ? boat.charterPrice : boat.perPersonPrice * form.passengers;
  const deposit = form.bookingType === 'charter' ? 500 : 100 * form.passengers;

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setForm(prev => ({
      ...prev,
      [name]: name === 'passengers' ? Math.min(Math.max(1, parseInt(value) || 1), maxPassengers) : value,
    }));
    setResult(null);
  };

  const handleBoatSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const value = e.target.value as 'kingfisher' | 'axpor';
    setForm(prev => ({
      ...prev,
      boatId: value,
      passengers: Math.min(prev.passengers, BOATS[value].maxPassengers),
    }));
    setResult(null);
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setResult(null);
    try {
      const res = await fetch('/api/booking', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...form, lang }),
      });
      const data = await res.json();

      if (data.success && form.paymentMethod === 'credit_card') {
        // Redirect to Stripe Checkout for credit card payments
        const boatName = form.boatId === 'kingfisher' ? 'Kingfisher 3025' : 'Axopar 37';
        const stripeRes = await fetch('/api/stripe', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            bookingId: data.bookingId,
            deposit,
            boatName,
            date: form.date,
            customerEmail: form.email,
          }),
        });
        const stripeData = await stripeRes.json();
        if (stripeData.url) {
          window.location.href = stripeData.url;
          return;
        }
      }

      setResult({
        success: data.success,
        message: data.success ? t.booking.success : t.booking.error,
        bookingId: data.bookingId,
        paymentMethod: form.paymentMethod,
      });
      if (data.success) {
        setForm({ boatId: 'kingfisher', bookingType: 'charter', date: '', passengers: 1, name: '', phone: '', email: '', wechat: '', paymentMethod: 'credit_card', notes: '' });
      }
    } catch {
      setResult({ success: false, message: t.booking.error });
    } finally {
      setSubmitting(false);
    }
  };

  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const minDate = tomorrow.toISOString().split('T')[0];

  const inputCls = "w-full border border-drift-200 rounded-xl px-4 py-3 text-drift-800 text-sm focus:outline-none focus:ring-2 focus:ring-sea-400 focus:border-transparent bg-white placeholder:text-drift-300 transition-shadow";

  return (
    <section id="booking" className="py-24 bg-gradient-to-br from-sea-900 via-sea-800 to-sea-950 relative overflow-hidden">
      {/* Decorative */}
      <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-sea-400/5 rounded-full blur-3xl" />
      <div className="absolute bottom-0 left-0 w-[400px] h-[400px] bg-coral-500/5 rounded-full blur-3xl" />

      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        <div className="text-center mb-12">
          <span className="text-sea-300 text-sm font-semibold tracking-wider uppercase">Reservation</span>
          <h2 className="text-3xl md:text-4xl font-heading font-extrabold text-white mt-3 mb-4">
            {t.booking.title}
          </h2>
          <p className="text-sea-200/60 text-base max-w-lg mx-auto">{t.booking.subtitle}</p>
        </div>

        <form onSubmit={handleSubmit} className="bg-white rounded-3xl shadow-2xl shadow-black/20 p-6 sm:p-8">
          {/* Boat & Type */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-5 mb-6">
            <div>
              <label htmlFor="boat-select" className="block text-xs font-semibold text-drift-700 mb-2 uppercase tracking-wide">
                {t.booking.boatSelect}
              </label>
              <select id="boat-select" name="boatId" value={form.boatId} onChange={handleBoatSelectChange} className={inputCls}>
                <option value="kingfisher">Kingfisher 3025 — 30ft</option>
                <option value="axpor">Axopar 37 — 37ft</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-semibold text-drift-700 mb-2 uppercase tracking-wide">
                {t.booking.bookingType}
              </label>
              <div className="grid grid-cols-2 gap-2">
                {(['charter', 'shared'] as const).map(type => (
                  <button
                    key={type}
                    type="button"
                    onClick={() => setForm(prev => ({ ...prev, bookingType: type }))}
                    className={`py-3 rounded-xl text-sm font-semibold border-2 transition-all ${
                      form.bookingType === type
                        ? 'border-sea-500 bg-sea-50 text-sea-700'
                        : 'border-drift-200 bg-white text-drift-500 hover:border-drift-300'
                    }`}
                  >
                    {type === 'charter' ? (lang === 'zh' ? '包船' : 'Charter') : (lang === 'zh' ? '拼船' : 'Shared')}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Date & Passengers */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-5 mb-6">
            <div>
              <label htmlFor="date" className="block text-xs font-semibold text-drift-700 mb-2 uppercase tracking-wide">{t.booking.date}</label>
              <input type="date" id="date" name="date" value={form.date} min={minDate} onChange={handleChange} required className={inputCls} />
            </div>
            <div>
              <label htmlFor="passengers" className="block text-xs font-semibold text-drift-700 mb-2 uppercase tracking-wide">
                {t.booking.passengers} <span className="normal-case text-drift-400">({lang === 'zh' ? `最多${maxPassengers}人` : `max ${maxPassengers}`})</span>
              </label>
              <input type="number" id="passengers" name="passengers" value={form.passengers} min={1} max={maxPassengers} onChange={handleChange} required className={inputCls} />
            </div>
          </div>

          {/* Price summary */}
          <div className="bg-drift-50 rounded-2xl p-5 mb-6 flex flex-col sm:flex-row justify-between items-center gap-3 border border-drift-100">
            <div className="flex items-baseline gap-2">
              <span className="text-xs text-drift-400 font-medium">{t.booking.totalPrice}</span>
              <span className="text-2xl font-extrabold text-drift-900">${totalPrice.toLocaleString()}</span>
              <span className="text-xs text-drift-400">CAD</span>
            </div>
            <div className="flex items-baseline gap-2">
              <span className="text-xs text-drift-400 font-medium">{t.booking.depositAmount}</span>
              <span className="text-lg font-bold text-coral-600">${deposit.toLocaleString()}</span>
              <span className="text-xs text-drift-400">CAD</span>
            </div>
          </div>

          {/* Contact info */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-5 mb-6">
            <div>
              <label htmlFor="name" className="block text-xs font-semibold text-drift-700 mb-2 uppercase tracking-wide">{t.booking.name}</label>
              <input type="text" id="name" name="name" value={form.name} onChange={handleChange} required placeholder={t.booking.namePlaceholder} className={inputCls} />
            </div>
            <div>
              <label htmlFor="phone" className="block text-xs font-semibold text-drift-700 mb-2 uppercase tracking-wide">{t.booking.phone}</label>
              <input type="tel" id="phone" name="phone" value={form.phone} onChange={handleChange} required placeholder={t.booking.phonePlaceholder} className={inputCls} />
            </div>
            <div>
              <label htmlFor="email" className="block text-xs font-semibold text-drift-700 mb-2 uppercase tracking-wide">{t.booking.email}</label>
              <input type="email" id="email" name="email" value={form.email} onChange={handleChange} required placeholder={t.booking.emailPlaceholder} className={inputCls} />
            </div>
            <div>
              <label htmlFor="wechat" className="block text-xs font-semibold text-drift-700 mb-2 uppercase tracking-wide">{t.booking.wechat}</label>
              <input type="text" id="wechat" name="wechat" value={form.wechat} onChange={handleChange} placeholder={t.booking.wechatPlaceholder} className={inputCls} />
            </div>
          </div>

          {/* Payment */}
          <div className="mb-6">
            <label className="block text-xs font-semibold text-drift-700 mb-3 uppercase tracking-wide">{t.booking.payment}</label>
            <div className="grid grid-cols-3 gap-3">
              <button
                type="button"
                onClick={() => setForm(prev => ({ ...prev, paymentMethod: 'wechat' }))}
                className={`flex flex-col items-center justify-center gap-1.5 py-3.5 rounded-xl border-2 transition-all text-xs font-semibold ${
                  form.paymentMethod === 'wechat'
                    ? 'border-green-500 bg-green-50 text-green-700'
                    : 'border-drift-200 bg-white text-drift-500 hover:border-drift-300'
                }`}
              >
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor"><path d="M8.691 2.188C3.891 2.188 0 5.476 0 9.53c0 2.212 1.17 4.203 3.002 5.55a.59.59 0 01.213.665l-.39 1.48c-.019.07-.048.141-.048.213 0 .163.13.295.29.295a.326.326 0 00.167-.054l1.903-1.114a.864.864 0 01.717-.098 10.16 10.16 0 002.837.403c.276 0 .543-.027.811-.05-.857-2.578.157-4.972 1.932-6.446 1.703-1.415 3.882-1.98 5.853-1.838-.576-3.583-4.196-6.348-8.596-6.348z"/></svg>
                {t.booking.wechatPay}
              </button>
              <button
                type="button"
                onClick={() => setForm(prev => ({ ...prev, paymentMethod: 'e_transfer' }))}
                className={`flex flex-col items-center justify-center gap-1.5 py-3.5 rounded-xl border-2 transition-all text-xs font-semibold ${
                  form.paymentMethod === 'e_transfer'
                    ? 'border-amber-500 bg-amber-50 text-amber-700'
                    : 'border-drift-200 bg-white text-drift-500 hover:border-drift-300'
                }`}
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M2.25 18.75a60.07 60.07 0 0115.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 013 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 00-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 01-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 003 15h-.75M15 10.5a3 3 0 11-6 0 3 3 0 016 0zm3 0h.008v.008H18V10.5zm-12 0h.008v.008H6V10.5z" /></svg>
                {t.booking.eTransfer}
              </button>
              <button
                type="button"
                onClick={() => setForm(prev => ({ ...prev, paymentMethod: 'credit_card' }))}
                className={`flex flex-col items-center justify-center gap-1.5 py-3.5 rounded-xl border-2 transition-all text-xs font-semibold ${
                  form.paymentMethod === 'credit_card'
                    ? 'border-sea-500 bg-sea-50 text-sea-700'
                    : 'border-drift-200 bg-white text-drift-500 hover:border-drift-300'
                }`}
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" /></svg>
                {t.booking.creditCard}
              </button>
            </div>
          </div>

          {/* Notes */}
          <div className="mb-6">
            <label htmlFor="notes" className="block text-xs font-semibold text-drift-700 mb-2 uppercase tracking-wide">{t.booking.notes}</label>
            <textarea id="notes" name="notes" value={form.notes} onChange={handleChange} rows={3} placeholder={t.booking.notesPlaceholder} className={inputCls + ' resize-none'} />
          </div>

          <p className="text-xs text-drift-400 mb-5 text-center">{t.booking.depositNote}</p>

          {result && (
            <div className={`mb-5 p-5 rounded-xl text-center text-sm font-medium ${
              result.success ? 'bg-green-50 text-green-800 border border-green-200' : 'bg-red-50 text-red-700 border border-red-200'
            }`}>
              <p className="font-bold mb-1">{result.message}</p>
              {result.success && result.bookingId && (
                <p className="text-xs opacity-75 mb-2">{lang === 'zh' ? '订单号' : 'Booking ID'}: {result.bookingId}</p>
              )}
              {result.success && result.paymentMethod && (
                <div className="mt-3 pt-3 border-t border-green-200 text-left">
                  <p className="text-xs font-bold uppercase tracking-wide mb-1">{lang === 'zh' ? '付款指引' : 'Payment Instructions'}</p>
                  <p className="text-sm">{t.booking.paymentInstructions[result.paymentMethod as keyof typeof t.booking.paymentInstructions]}</p>
                </div>
              )}
            </div>
          )}

          <button
            type="submit"
            disabled={submitting}
            className="w-full bg-coral-500 hover:bg-coral-600 text-white font-bold text-base py-4 rounded-xl transition-all hover:shadow-lg hover:shadow-coral-500/25 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {submitting ? (
              <span className="flex items-center justify-center gap-2">
                <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" /><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" /></svg>
                {lang === 'zh' ? '提交中...' : 'Submitting...'}
              </span>
            ) : t.booking.submit}
          </button>
        </form>
      </div>
    </section>
  );
}
