'use client';

import { useLanguage } from '@/i18n/LanguageContext';
import AnimateOnScroll from './AnimateOnScroll';

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
  { bg: 'bg-green-500/10', border: 'border-green-500/20', icon: 'text-green-400', badge: 'bg-green-500/15 text-green-400' },
  { bg: 'bg-sky-500/10', border: 'border-sky-500/20', icon: 'text-sky-400', badge: 'bg-sky-500/15 text-sky-400' },
  { bg: 'bg-amber-500/10', border: 'border-amber-500/20', icon: 'text-amber-400', badge: 'bg-amber-500/15 text-amber-400' },
];

export default function Policy() {
  const { t } = useLanguage();

  return (
    <section id="policy" className="py-24">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-14">
          <span className="text-gold-400 text-sm font-semibold tracking-wider uppercase">{t.sections?.policy || 'Policy'}</span>
          <h2 className="text-3xl md:text-4xl font-heading font-extrabold text-white mt-3 mb-4">
            {t.policy.title}
          </h2>
          <p className="text-white/60 text-base max-w-lg mx-auto">{t.policy.subtitle}</p>
          <div className="w-12 h-1 bg-gradient-to-r from-gold-400 to-gold-500 mx-auto rounded-full mt-4" />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          {t.policy.items.map((item, i) => (
            <AnimateOnScroll key={i} delay={i * 100}>
              <div
                className={`rounded-2xl p-6 border ${colors[i].bg} ${colors[i].border} transition-all hover:shadow-lg hover:-translate-y-1 duration-300 h-full`}
              >
                <div className={`w-12 h-12 rounded-xl ${colors[i].badge} flex items-center justify-center mb-5`}>
                  {policyIcons[i]}
                </div>
                <h3 className="text-base font-bold text-white mb-2">{item.title}</h3>
                <p className="text-white/60 text-sm leading-relaxed">{item.desc}</p>
              </div>
            </AnimateOnScroll>
          ))}
        </div>
      </div>
    </section>
  );
}
