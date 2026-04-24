'use client';

import { useLanguage } from '@/i18n/LanguageContext';

const policyIcons = [
  <svg key="check" className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
  </svg>,
  <svg key="cloud" className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M2.25 15a4.5 4.5 0 004.5 4.5H18a3.75 3.75 0 001.332-7.257 3 3 0 00-3.758-3.848 5.25 5.25 0 00-10.233 2.33A4.502 4.502 0 002.25 15z" />
  </svg>,
  <svg key="info" className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z" />
  </svg>,
];

const colors = [
  { bg: 'bg-green-50', border: 'border-green-100', icon: 'text-green-600', badge: 'bg-green-100 text-green-700' },
  { bg: 'bg-sky-50', border: 'border-sky-100', icon: 'text-sky-600', badge: 'bg-sky-100 text-sky-700' },
  { bg: 'bg-amber-50', border: 'border-amber-100', icon: 'text-amber-600', badge: 'bg-amber-100 text-amber-700' },
];

export default function Policy() {
  const { t } = useLanguage();

  return (
    <section id="policy" className="py-24 bg-white">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-14">
          <span className="text-sea-600 text-sm font-semibold tracking-wider uppercase">Policy</span>
          <h2 className="text-3xl md:text-4xl font-heading font-extrabold text-drift-950 mt-3 mb-4">
            {t.policy.title}
          </h2>
          <p className="text-drift-500 text-base max-w-lg mx-auto">{t.policy.subtitle}</p>
          <div className="w-12 h-1 bg-gradient-to-r from-sea-500 to-coral-400 mx-auto rounded-full mt-4" />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          {t.policy.items.map((item, i) => (
            <div
              key={i}
              className={`rounded-2xl p-6 border ${colors[i].bg} ${colors[i].border} transition-all hover:shadow-lg hover:-translate-y-1 duration-300`}
            >
              <div className={`w-12 h-12 rounded-xl ${colors[i].badge} flex items-center justify-center mb-5`}>
                {policyIcons[i]}
              </div>
              <h3 className="text-base font-bold text-drift-900 mb-2">{item.title}</h3>
              <p className="text-drift-500 text-sm leading-relaxed">{item.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
