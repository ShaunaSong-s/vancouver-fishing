'use client';

import { useState, useEffect } from 'react';
import { useLanguage } from '@/i18n/LanguageContext';
import { useMember } from '@/lib/MemberContext';

interface Booking {
  bookingId: string;
  boatName: string;
  bookingType: string;
  tripDate: string;
  passengers: number;
  totalPrice: number;
  status: string;
  source: string;
  createdAt: string;
}

export default function MyBookings() {
  const { lang } = useLanguage();
  const { member } = useMember();
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(false);
  const [showPanel, setShowPanel] = useState(false);

  useEffect(() => {
    if (member && showPanel) {
      setLoading(true);
      fetch(`/api/member/bookings?phone=${encodeURIComponent(member.phone)}`)
        .then(r => r.json())
        .then(data => {
          if (data.success) setBookings(data.bookings);
          setLoading(false);
        })
        .catch(() => setLoading(false));
    }
  }, [member, showPanel]);

  if (!member) return null;

  const statusMap: Record<string, { label: string; color: string }> = {
    pending: { label: lang === 'zh' ? '待确认' : 'Pending', color: 'bg-amber-500/15 text-amber-400' },
    confirmed: { label: lang === 'zh' ? '已确认' : 'Confirmed', color: 'bg-green-500/15 text-green-400' },
    completed: { label: lang === 'zh' ? '已完成' : 'Completed', color: 'bg-gold-400/15 text-gold-400' },
    cancelled: { label: lang === 'zh' ? '已取消' : 'Cancelled', color: 'bg-red-500/15 text-red-400' },
  };

  return (
    <>
      <button
        onClick={() => setShowPanel(true)}
        className="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg border border-gold-400/20 text-gold-400/80 hover:border-gold-400/40 hover:text-gold-400 hover:bg-gold-400/5 transition-all"
      >
        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75 2.25 2.25 0 00-.1-.664m-5.8 0A2.251 2.251 0 0113.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25zM6.75 12h.008v.008H6.75V12zm0 3h.008v.008H6.75V15zm0 3h.008v.008H6.75V18z" />
        </svg>
        {lang === 'zh' ? '我的预约' : 'My Bookings'}
      </button>

      {/* Slide-over panel */}
      {showPanel && (
        <div className="fixed inset-0 z-[100] flex justify-end">
          <div className="absolute inset-0 bg-black/30 backdrop-blur-sm" onClick={() => setShowPanel(false)} />
          <div className="relative w-full max-w-md bg-sea-900 shadow-2xl overflow-y-auto animate-slide-in-right border-l border-gold-400/10">
            {/* Header */}
            <div className="sticky top-0 bg-sea-900/95 backdrop-blur-md border-b border-gold-400/10 px-5 py-4 flex items-center justify-between z-10">
              <h2 className="text-base font-bold text-white">
                {lang === 'zh' ? '我的预约记录' : 'My Bookings'}
              </h2>
              <button onClick={() => setShowPanel(false)} className="text-white/40 hover:text-white">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <div className="p-5">
              {loading ? (
                <div className="flex items-center justify-center py-12">
                  <svg className="animate-spin h-6 w-6 text-gold-400" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                </div>
              ) : bookings.length === 0 ? (
                <div className="text-center py-12">
                  <svg className="w-12 h-12 text-white/10 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5" />
                  </svg>
                  <p className="text-white/40 text-sm">{lang === 'zh' ? '暂无预约记录' : 'No bookings yet'}</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {bookings.map((b) => {
                    const s = statusMap[b.status] || statusMap.pending;
                    const isPast = new Date(b.tripDate) < new Date();
                    return (
                      <div
                        key={b.bookingId}
                        className={`rounded-xl border p-4 transition-all ${isPast ? 'border-white/5 bg-white/[0.02]' : 'border-gold-400/10 bg-white/5'}`}
                      >
                        <div className="flex items-start justify-between mb-2">
                          <div>
                            <div className="font-semibold text-sm text-white">{b.boatName}</div>
                            <div className="text-xs text-white/40 mt-0.5">{b.bookingId}</div>
                          </div>
                          <span className={`text-[10px] font-semibold px-2 py-0.5 rounded-md ${s.color}`}>
                            {s.label}
                          </span>
                        </div>
                        <div className="grid grid-cols-2 gap-x-4 gap-y-1 text-xs text-white/60 mt-3">
                          <div className="flex items-center gap-1.5">
                            <svg className="w-3.5 h-3.5 text-white/30" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                              <path strokeLinecap="round" strokeLinejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5" />
                            </svg>
                            {b.tripDate}
                          </div>
                          <div className="flex items-center gap-1.5">
                            <svg className="w-3.5 h-3.5 text-white/30" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z" />
                            </svg>
                            {b.passengers}{lang === 'zh' ? '人' : ' pax'}
                          </div>
                          <div className="flex items-center gap-1.5">
                            <svg className="w-3.5 h-3.5 text-white/30" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                              <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v12m-3-2.818l.879.659c1.171.879 3.07.879 4.242 0 1.172-.879 1.172-2.303 0-3.182C13.536 12.219 12.768 12 12 12c-.725 0-1.45-.22-2.003-.659-1.106-.879-1.106-2.303 0-3.182s2.9-.879 4.006 0l.415.33M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            ${b.totalPrice?.toLocaleString()} CAD
                          </div>
                          <div className="flex items-center gap-1.5">
                            <svg className="w-3.5 h-3.5 text-white/30" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                              <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
                            </svg>
                            {b.bookingType === 'charter' ? (lang === 'zh' ? '包船' : 'Charter') : (lang === 'zh' ? '拼船' : 'Shared')}
                          </div>
                        </div>
                        {b.source && (
                          <div className="mt-2 text-[10px] text-white/30">
                            {lang === 'zh' ? '来源：' : 'Via: '}{b.source === 'website' ? (lang === 'zh' ? '网站' : 'Website') : (lang === 'zh' ? '小程序' : 'Mini App')}
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
}
