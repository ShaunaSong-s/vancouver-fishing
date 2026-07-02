'use client';

import { useLanguage } from '@/i18n/LanguageContext';
import { BOATS } from '@/lib/types';
import { useMember } from '@/lib/MemberContext';
import { useState, useEffect, FormEvent } from 'react';

type Step = 1 | 2 | 3;

export default function BookingForm() {
  const { t, lang } = useLanguage();
  const { member } = useMember();

  // ── Booking system paused ──
  const BOOKING_PAUSED = true;

  const [step, setStep] = useState<Step>(1);
  const [form, setForm] = useState({
    boatId: 'kingfisher' as 'kingfisher' | 'axpor',
    bookingType: 'charter' as 'charter' | 'shared',
    date: '',
    passengers: 1,
    name: '',
    phone: '',
    email: '',
    wechat: '',
    paymentMethod: 'wechat' as 'wechat' | 'e_transfer',
    notes: '',
  });

  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState<{ success: boolean; message: string; bookingId?: string; paymentMethod?: string } | null>(null);
  const [availability, setAvailability] = useState<{ available: boolean; remainingSpots: number; charterBlocked: boolean } | null>(null);
  const [checkingAvailability, setCheckingAvailability] = useState(false);

  const boat = BOATS[form.boatId];
  const boatMax = boat.maxPassengers;
  // For shared trips, cap passengers to remaining spots from availability check
  const maxPassengers = (form.bookingType === 'shared' && availability?.available && availability.remainingSpots < boatMax)
    ? availability.remainingSpots
    : boatMax;
  const totalPrice = form.bookingType === 'charter' ? boat.charterPrice : boat.perPersonPrice * form.passengers;
  const deposit = form.bookingType === 'charter' ? 500 : 100 * form.passengers;

  // Check availability when date or boat changes
  useEffect(() => {
    if (!form.date || !form.boatId) {
      setAvailability(null);
      return;
    }

    const controller = new AbortController();
    setCheckingAvailability(true);

    fetch(`/api/booking/availability?boatId=${form.boatId}&date=${form.date}`, { signal: controller.signal })
      .then(r => r.json())
      .then(data => {
        setAvailability(data);
        // Clamp passengers to remaining spots for shared trips
        if (data.available && data.remainingSpots < boat.maxPassengers && form.bookingType === 'shared') {
          setForm(prev => ({ ...prev, passengers: Math.min(prev.passengers, data.remainingSpots) }));
        }
        setCheckingAvailability(false);
      })
      .catch(() => {
        setCheckingAvailability(false);
      });

    return () => controller.abort();
  }, [form.date, form.boatId]);

  // Auto-fill contact info from member profile
  useEffect(() => {
    if (member && !form.name && !form.phone) {
      setForm(prev => ({
        ...prev,
        name: member.name || prev.name,
        phone: member.phone || prev.phone,
      }));
    }
  }, [member]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setForm(prev => ({
      ...prev,
      [name]: name === 'passengers' ? Math.min(Math.max(1, parseInt(value) || 1), maxPassengers) : value,
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
        body: JSON.stringify({ ...form, lang, memberNo: member?.memberNo || '' }),
      });
      const data = await res.json();



      setResult({
        success: data.success,
        message: data.success ? t.booking.success : t.booking.error,
        bookingId: data.bookingId,
        paymentMethod: form.paymentMethod,
      });
      if (data.success) {
        setForm({ boatId: 'kingfisher', bookingType: 'charter', date: '', passengers: 1, name: '', phone: '', email: '', wechat: '', paymentMethod: 'wechat', notes: '' });
        setStep(1);
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

  const inputCls = "w-full border border-gold-400/15 rounded-xl px-4 py-3.5 text-white text-sm focus:outline-none focus:ring-2 focus:ring-gold-400/50 focus:border-transparent bg-white/5 placeholder:text-white/30 transition-all";

  const canGoStep2 = form.boatId && form.bookingType && form.date && form.passengers >= 1 &&
    (!availability || availability.available);
  const canGoStep3 = canGoStep2 && form.name && form.phone && form.email;

  const stepLabels = lang === 'zh'
    ? ['选择行程', '联系方式', '确认付款']
    : ['Trip Details', 'Contact Info', 'Confirm & Pay'];

  if (BOOKING_PAUSED) {
    return (
      <section id="booking" className="py-24 relative overflow-hidden">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 relative text-center">
          <span className="text-gold-400 text-sm font-semibold tracking-wider uppercase">{t.sections?.booking || 'Reservation'}</span>
          <h2 className="text-3xl md:text-4xl font-heading font-extrabold text-white mt-3 mb-4">
            {t.booking.title}
          </h2>
          <div className="glass rounded-3xl shadow-2xl shadow-black/30 p-8 sm:p-12 mt-8">
            <p className="text-white/80 text-lg">
              {lang === 'zh'
                ? '⚓ 预约系统暂时关闭，请稍后再来或直接联系我们。'
                : '⚓ Online booking is currently paused. Please contact us directly to arrange your trip.'}
            </p>
          </div>
        </div>
      </section>
    );
  }

  return (
    <section id="booking" className="py-24 relative overflow-hidden">
      {/* Decorative */}
      <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-gold-400/5 rounded-full blur-3xl" />
      <div className="absolute bottom-0 left-0 w-[400px] h-[400px] bg-gold-500/5 rounded-full blur-3xl" />

      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        <div className="text-center mb-12">
          <span className="text-gold-400 text-sm font-semibold tracking-wider uppercase">{t.sections?.booking || 'Reservation'}</span>
          <h2 className="text-3xl md:text-4xl font-heading font-extrabold text-white mt-3 mb-4">
            {t.booking.title}
          </h2>
          <p className="text-white/60 text-base max-w-lg mx-auto">{t.booking.subtitle}</p>
        </div>

        <form onSubmit={handleSubmit} className="glass rounded-3xl shadow-2xl shadow-black/30 p-6 sm:p-8">
          {/* Progress Steps */}
          <div className="flex items-center justify-between mb-8 px-2">
            {[1, 2, 3].map((s) => (
              <div key={s} className="flex items-center flex-1">
                <div className="flex flex-col items-center">
                  <div
                    className={`w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold transition-all duration-300 ${
                      step >= s
                        ? 'bg-gold-400 text-sea-900 shadow-md shadow-gold-400/30'
                        : 'bg-white/10 text-white/40'
                    }`}
                  >
                    {step > s ? (
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={3}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                    ) : s}
                  </div>
                  <span className={`text-[10px] mt-1.5 font-medium ${step >= s ? 'text-gold-400' : 'text-white/40'}`}>
                    {stepLabels[s - 1]}
                  </span>
                </div>
                {s < 3 && (
                  <div className={`flex-1 h-0.5 mx-3 mt-[-14px] rounded-full transition-all duration-500 ${
                    step > s ? 'bg-gold-400' : 'bg-white/10'
                  }`} />
                )}
              </div>
            ))}
          </div>

          {/* Step 1: Trip Details */}
          <div className={`transition-all duration-300 ${step === 1 ? 'block' : 'hidden'}`}>
            {/* Boat Selection - Visual Cards */}
            <label className="block text-xs font-semibold text-gold-400/80 mb-3 uppercase tracking-wide">
              {t.booking.boatSelect}
            </label>
            <div className="grid grid-cols-2 gap-3 mb-6">
              {(['kingfisher', 'axpor'] as const).map((id) => {
                const b = BOATS[id];
                const isSelected = form.boatId === id;
                return (
                  <button
                    key={id}
                    type="button"
                    onClick={() => {
                      setForm(prev => ({ ...prev, boatId: id, passengers: Math.min(prev.passengers, b.maxPassengers) }));
                      setResult(null);
                    }}
                    className={`relative p-4 rounded-2xl border-2 text-left transition-all duration-200 ${
                      isSelected
                        ? 'border-gold-400 bg-gold-400/10 shadow-md shadow-gold-400/10'
                        : 'border-white/10 bg-white/5 hover:border-white/20'
                    }`}
                  >
                    {isSelected && (
                      <div className="absolute top-2 right-2 w-5 h-5 bg-gold-400 rounded-full flex items-center justify-center">
                        <svg className="w-3 h-3 text-sea-900" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={3}>
                          <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                        </svg>
                      </div>
                    )}
                    <div className="font-bold text-sm text-white">
                      {id === 'kingfisher' ? 'Kingfisher 3025' : 'Axopar 37'}
                    </div>
                    <div className="text-xs text-white/50 mt-1">{b.length}ft · {lang === 'zh' ? `最多${b.maxPassengers}人` : `Up to ${b.maxPassengers}`}</div>
                    <div className="mt-2 flex gap-2">
                      <span className="text-[10px] bg-white/5 text-gold-500 px-2 py-0.5 rounded-md font-medium">
                        {lang === 'zh' ? '包船' : 'Charter'} ${b.charterPrice.toLocaleString()}
                      </span>
                      <span className="text-[10px] bg-white/5 text-gold-500 px-2 py-0.5 rounded-md font-medium">
                        {lang === 'zh' ? '拼船' : 'Shared'} ${b.perPersonPrice}/{lang === 'zh' ? '人' : 'pp'}
                      </span>
                    </div>
                  </button>
                );
              })}
            </div>

            {/* Booking Type */}
            <label className="block text-xs font-semibold text-gold-400/80 mb-3 uppercase tracking-wide">
              {t.booking.bookingType}
            </label>
            <div className="grid grid-cols-2 gap-3 mb-6">
              {(['charter', 'shared'] as const).map(type => (
                <button
                  key={type}
                  type="button"
                  onClick={() => setForm(prev => ({ ...prev, bookingType: type }))}
                  className={`py-4 rounded-xl text-sm font-semibold border-2 transition-all ${
                    form.bookingType === type
                      ? 'border-gold-400 bg-gold-400/10 text-gold-400'
                      : 'border-white/10 bg-white/5 text-white/60 hover:border-white/20'
                  }`}
                >
                  <div>{type === 'charter' ? (lang === 'zh' ? '🚤 包船' : '🚤 Charter') : (lang === 'zh' ? '👥 拼船' : '👥 Shared')}</div>
                  <div className="text-[10px] text-white/40 mt-1 font-normal">
                    {type === 'charter' ? (lang === 'zh' ? '独享整条船' : 'Private boat') : (lang === 'zh' ? '按人数计费' : 'Per person')}
                  </div>
                </button>
              ))}
            </div>

            {/* Date & Passengers */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
              <div>
                <label htmlFor="date" className="block text-xs font-semibold text-gold-400/80 mb-2 uppercase tracking-wide">{t.booking.date}</label>
                <input type="date" id="date" name="date" value={form.date} min={minDate} onChange={handleChange} required className={inputCls} />
              </div>
              <div>
                <label htmlFor="passengers" className="block text-xs font-semibold text-gold-400/80 mb-2 uppercase tracking-wide">
                  {t.booking.passengers} <span className="normal-case text-white/40">({lang === 'zh' ? `最多${maxPassengers}人` : `max ${maxPassengers}`})</span>
                </label>
                <input type="number" id="passengers" name="passengers" value={form.passengers} min={1} max={maxPassengers} onChange={handleChange} required className={inputCls} />
              </div>
            </div>

            {/* Availability Status */}
            {form.date && (
              <div className={`mb-6 p-3 rounded-xl text-sm font-medium flex items-center gap-2 ${
                checkingAvailability
                  ? 'bg-white/5 text-white/50 border border-white/10'
                  : availability?.available
                    ? 'bg-green-500/10 text-green-400 border border-green-500/20'
                    : 'bg-red-500/10 text-red-400 border border-red-500/20'
              }`}>
                {checkingAvailability ? (
                  <>
                    <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" /><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" /></svg>
                    {lang === 'zh' ? '正在检查可用性...' : 'Checking availability...'}
                  </>
                ) : availability?.available ? (
                  <>
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                    {lang === 'zh'
                      ? `可预定 · 剩余${availability.remainingSpots}个位`
                      : `Available · ${availability.remainingSpots} spots left`}
                  </>
                ) : availability?.charterBlocked ? (
                  <>
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" /></svg>
                    {lang === 'zh' ? '该日期已被包船，请选择其他日期' : 'This date is chartered, please pick another'}
                  </>
                ) : (
                  <>
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" /></svg>
                    {lang === 'zh' ? '该日期已满员，请选择其他日期' : 'No spots available, please pick another date'}
                  </>
                )}
              </div>
            )}

            {/* Price Preview */}
            <div className="bg-gradient-to-r from-gold-400/10 to-gold-500/5 rounded-2xl p-5 border border-gold-400/15 mb-6">
              <div className="flex justify-between items-center">
                <div>
                  <div className="text-[11px] text-white/50 font-medium uppercase tracking-wide">{t.booking.totalPrice}</div>
                  <div className="text-2xl font-extrabold text-gold-400 mt-0.5">${totalPrice.toLocaleString()} <span className="text-sm font-medium text-white/40">CAD</span></div>
                </div>
                <div className="text-right">
                  <div className="text-[11px] text-white/50 font-medium uppercase tracking-wide">{t.booking.depositAmount}</div>
                  <div className="text-lg font-bold text-gold-500 mt-0.5">${deposit.toLocaleString()} <span className="text-sm font-medium text-white/40">CAD</span></div>
                </div>
              </div>
            </div>

            <button
              type="button"
              disabled={!canGoStep2}
              onClick={() => setStep(2)}
              className="w-full btn-gold text-base py-4 rounded-xl transition-all disabled:opacity-40 disabled:cursor-not-allowed"
            >
              {lang === 'zh' ? '下一步 →' : 'Next →'}
            </button>
          </div>

          {/* Step 2: Contact Info */}
          <div className={`transition-all duration-300 ${step === 2 ? 'block' : 'hidden'}`}>
            {/* Member status hint */}
            {member ? (
              <div className="bg-gold-400/10 border border-gold-400/15 rounded-xl p-3 mb-5 flex items-center gap-2 text-sm text-gold-400">
                <svg className="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span className="font-medium">
                  {lang === 'zh' ? `已登录：${member.name}（${member.memberNo}）` : `Logged in: ${member.name} (${member.memberNo})`}
                </span>
              </div>
            ) : (
              <div className="bg-amber-500/10 border border-amber-500/15 rounded-xl p-3 mb-5 flex items-center gap-2 text-sm text-amber-400">
                <svg className="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
                </svg>
                <span>
                  {lang === 'zh' ? '登录会员可享受专属优惠，点击右上角注册/登录' : 'Login for member benefits — use the button in the top right'}
                </span>
              </div>
            )}

            {/* Trip summary bar */}
            <div className="bg-white/5 rounded-xl p-4 mb-6 flex flex-wrap items-center gap-x-4 gap-y-1 text-sm border border-white/10">
              <span className="font-semibold text-white">{form.boatId === 'kingfisher' ? 'Kingfisher 3025' : 'Axopar 37'}</span>
              <span className="text-white/20">|</span>
              <span className="text-white/60">{form.bookingType === 'charter' ? (lang === 'zh' ? '包船' : 'Charter') : (lang === 'zh' ? '拼船' : 'Shared')}</span>
              <span className="text-white/20">|</span>
              <span className="text-white/60">{form.date}</span>
              <span className="text-white/20">|</span>
              <span className="text-white/60">{form.passengers}{lang === 'zh' ? '人' : ' pax'}</span>
              <button type="button" onClick={() => setStep(1)} className="ml-auto text-xs text-gold-400 hover:text-gold-300 font-semibold">
                {lang === 'zh' ? '修改' : 'Edit'}
              </button>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-5">
              <div>
                <label htmlFor="name" className="block text-xs font-semibold text-gold-400/80 mb-2 uppercase tracking-wide">{t.booking.name}</label>
                <input type="text" id="name" name="name" value={form.name} onChange={handleChange} required placeholder={t.booking.namePlaceholder} className={inputCls} />
              </div>
              <div>
                <label htmlFor="phone" className="block text-xs font-semibold text-gold-400/80 mb-2 uppercase tracking-wide">{t.booking.phone}</label>
                <input type="tel" id="phone" name="phone" value={form.phone} onChange={handleChange} required placeholder={t.booking.phonePlaceholder} className={inputCls} />
              </div>
              <div>
                <label htmlFor="email" className="block text-xs font-semibold text-gold-400/80 mb-2 uppercase tracking-wide">{t.booking.email}</label>
                <input type="email" id="email" name="email" value={form.email} onChange={handleChange} required placeholder={t.booking.emailPlaceholder} className={inputCls} />
              </div>
              <div>
                <label htmlFor="wechat" className="block text-xs font-semibold text-gold-400/80 mb-2 uppercase tracking-wide">{t.booking.wechat}</label>
                <input type="text" id="wechat" name="wechat" value={form.wechat} onChange={handleChange} placeholder={t.booking.wechatPlaceholder} className={inputCls} />
              </div>
            </div>

            {/* Notes */}
            <div className="mb-6">
              <label htmlFor="notes" className="block text-xs font-semibold text-gold-400/80 mb-2 uppercase tracking-wide">{t.booking.notes}</label>
              <textarea id="notes" name="notes" value={form.notes} onChange={handleChange} rows={3} placeholder={t.booking.notesPlaceholder} className={inputCls + ' resize-none'} />
            </div>

            <div className="flex gap-3">
              <button
                type="button"
                onClick={() => setStep(1)}
                className="flex-1 border-2 border-gold-400/30 text-gold-400 font-semibold text-base py-3.5 rounded-xl transition-all hover:border-gold-400/50 hover:bg-gold-400/5"
              >
                {lang === 'zh' ? '← 上一步' : '← Back'}
              </button>
              <button
                type="button"
                disabled={!canGoStep3}
                onClick={() => setStep(3)}
                className="flex-[2] btn-gold text-base py-3.5 rounded-xl transition-all disabled:opacity-40 disabled:cursor-not-allowed"
              >
                {lang === 'zh' ? '下一步 →' : 'Next →'}
              </button>
            </div>
          </div>

          {/* Step 3: Confirm & Pay */}
          <div className={`transition-all duration-300 ${step === 3 ? 'block' : 'hidden'}`}>
            {/* Order Summary */}
            <div className="bg-white/5 rounded-2xl p-5 mb-6 border border-white/10">
              <h3 className="text-sm font-bold text-white mb-3">{lang === 'zh' ? '订单确认' : 'Order Summary'}</h3>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-white/50">{lang === 'zh' ? '船只' : 'Boat'}</span>
                  <span className="font-medium text-white">{form.boatId === 'kingfisher' ? 'Kingfisher 3025' : 'Axopar 37'}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-white/50">{lang === 'zh' ? '类型' : 'Type'}</span>
                  <span className="font-medium text-white">{form.bookingType === 'charter' ? (lang === 'zh' ? '包船' : 'Charter') : (lang === 'zh' ? '拼船' : 'Shared')}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-white/50">{lang === 'zh' ? '日期' : 'Date'}</span>
                  <span className="font-medium text-white">{form.date}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-white/50">{lang === 'zh' ? '人数' : 'Guests'}</span>
                  <span className="font-medium text-white">{form.passengers}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-white/50">{lang === 'zh' ? '联系人' : 'Contact'}</span>
                  <span className="font-medium text-white">{form.name} · {form.phone}</span>
                </div>
                <div className="border-t border-white/10 pt-2 mt-2">
                  <div className="flex justify-between">
                    <span className="text-white/70 font-semibold">{t.booking.totalPrice}</span>
                    <span className="text-lg font-extrabold text-gold-400">${totalPrice.toLocaleString()} CAD</span>
                  </div>
                  <div className="flex justify-between mt-1">
                    <span className="text-white/50">{lang === 'zh' ? '今日支付定金' : 'Deposit due today'}</span>
                    <span className="font-bold text-gold-500">${deposit.toLocaleString()} CAD</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Payment Method */}
            <div className="mb-6">
              <label className="block text-xs font-semibold text-gold-400/80 mb-3 uppercase tracking-wide">{t.booking.payment}</label>
              <div className="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => setForm(prev => ({ ...prev, paymentMethod: 'wechat' }))}
                  className={`flex flex-col items-center justify-center gap-1.5 py-4 rounded-xl border-2 transition-all text-xs font-semibold ${
                    form.paymentMethod === 'wechat'
                      ? 'border-green-400 bg-green-500/10 text-green-400 shadow-sm shadow-green-500/10'
                      : 'border-white/10 bg-white/5 text-white/50 hover:border-white/20'
                  }`}
                >
                  <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor"><path d="M8.691 2.188C3.891 2.188 0 5.476 0 9.53c0 2.212 1.17 4.203 3.002 5.55a.59.59 0 01.213.665l-.39 1.48c-.019.07-.048.141-.048.213 0 .163.13.295.29.295a.326.326 0 00.167-.054l1.903-1.114a.864.864 0 01.717-.098 10.16 10.16 0 002.837.403c.276 0 .543-.027.811-.05-.857-2.578.157-4.972 1.932-6.446 1.703-1.415 3.882-1.98 5.853-1.838-.576-3.583-4.196-6.348-8.596-6.348z"/></svg>
                  {t.booking.wechatPay}
                </button>
                <button
                  type="button"
                  onClick={() => setForm(prev => ({ ...prev, paymentMethod: 'e_transfer' }))}
                  className={`flex flex-col items-center justify-center gap-1.5 py-4 rounded-xl border-2 transition-all text-xs font-semibold ${
                    form.paymentMethod === 'e_transfer'
                      ? 'border-amber-400 bg-amber-500/10 text-amber-400 shadow-sm shadow-amber-500/10'
                      : 'border-white/10 bg-white/5 text-white/50 hover:border-white/20'
                  }`}
                >
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M2.25 18.75a60.07 60.07 0 0115.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 013 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 00-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 01-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 003 15h-.75M15 10.5a3 3 0 11-6 0 3 3 0 016 0zm3 0h.008v.008H18V10.5zm-12 0h.008v.008H6V10.5z" /></svg>
                  {t.booking.eTransfer}
                </button>
              </div>
            </div>

            <p className="text-xs text-white/40 mb-5 text-center">{t.booking.depositNote}</p>

            {result && (
              <div className={`mb-5 p-5 rounded-xl text-center text-sm font-medium ${
                result.success ? 'bg-gold-400/10 text-gold-400 border border-gold-400/20' : 'bg-red-500/10 text-red-400 border border-red-500/20'
              }`}>
                <p className="font-bold mb-1">{result.message}</p>
                {result.success && result.bookingId && (
                  <p className="text-xs opacity-75 mb-2">{lang === 'zh' ? '订单号' : 'Booking ID'}: {result.bookingId}</p>
                )}
                {result.success && result.paymentMethod && (
                  <div className="mt-3 pt-3 border-t border-gold-400/20 text-left">
                    <p className="text-xs font-bold uppercase tracking-wide mb-1">{lang === 'zh' ? '付款指引' : 'Payment Instructions'}</p>
                    <p className="text-sm">{t.booking.paymentInstructions[result.paymentMethod as keyof typeof t.booking.paymentInstructions]}</p>
                  </div>
                )}
              </div>
            )}

            <div className="flex gap-3">
              <button
                type="button"
                onClick={() => setStep(2)}
                className="flex-1 border-2 border-gold-400/30 text-gold-400 font-semibold text-base py-3.5 rounded-xl transition-all hover:border-gold-400/50 hover:bg-gold-400/5"
              >
                {lang === 'zh' ? '← 上一步' : '← Back'}
              </button>
              <button
                type="submit"
                disabled={submitting}
                className="flex-[2] btn-gold text-base py-4 rounded-xl transition-all disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {submitting ? (
                  <span className="flex items-center justify-center gap-2">
                    <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" /><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" /></svg>
                    {lang === 'zh' ? '提交中...' : 'Submitting...'}
                  </span>
                ) : (
                  lang === 'zh' ? `确认并支付定金 $${deposit}` : `Confirm & Pay $${deposit} Deposit`
                )}
              </button>
            </div>
          </div>
        </form>
      </div>
    </section>
  );
}
