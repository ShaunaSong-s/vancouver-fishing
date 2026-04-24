'use client';

import { useLanguage } from '@/i18n/LanguageContext';

const icons = [
  <svg key="captain" className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}><path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z" /></svg>,
  <svg key="equip" className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}><path strokeLinecap="round" strokeLinejoin="round" d="M11.42 15.17l-5.384 5.383a2.034 2.034 0 01-2.87-2.87l5.383-5.384m0 0a1.998 1.998 0 013.357-.322L15.88 15.1a2 2 0 01-.322 3.357M3.75 21h16.5M12 6.75h.008v.008H12V6.75z" /></svg>,
  <svg key="flex" className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}><path strokeLinecap="round" strokeLinejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5" /></svg>,
  <svg key="lang" className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}><path strokeLinecap="round" strokeLinejoin="round" d="M10.5 21l5.25-11.25L21 21m-9-3h7.5M3 5.621a48.474 48.474 0 016-.371m0 0c1.12 0 2.233.038 3.334.114M9 5.25V3m3.334 2.364C11.176 10.658 7.69 15.08 3 17.502m9.334-12.138c.896.061 1.785.147 2.666.257m-4.589 8.495a18.023 18.023 0 01-3.827-5.802" /></svg>,
];

export default function About() {
  const { t, lang } = useLanguage();

  return (
    <section className="py-24 bg-drift-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section header */}
        <div className="text-center mb-16">
          <span className="text-sea-600 text-sm font-semibold tracking-wider uppercase">
            {t.sections?.about || 'Our Advantage'}
          </span>
          <h2 className="text-3xl md:text-4xl font-heading font-extrabold text-drift-950 mt-3 mb-4">
            {t.about.title}
          </h2>
          <div className="w-12 h-1 bg-gradient-to-r from-sea-500 to-coral-400 mx-auto rounded-full" />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
          {t.about.items.map((item, i) => (
            <div
              key={i}
              className="group bg-white rounded-2xl p-7 hover:shadow-xl hover:shadow-sea-500/5 transition-all duration-300 border border-drift-100 hover:border-sea-200 hover:-translate-y-1"
            >
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-sea-50 to-sea-100 text-sea-600 flex items-center justify-center mb-5 group-hover:from-sea-500 group-hover:to-sea-600 group-hover:text-white transition-all duration-300">
                {icons[i]}
              </div>
              <h3 className="text-base font-bold text-drift-900 mb-2">{item.title}</h3>
              <p className="text-drift-500 text-sm leading-relaxed">{item.desc}</p>
            </div>
          ))}
        </div>

        {/* Photo strip */}
        <div className="mt-16 grid grid-cols-2 md:grid-cols-4 gap-3">
          {[
            { src: '/images/catch-1.jpg', alt: lang === 'zh' ? '温哥华海钓三文鱼渔获' : 'Vancouver salmon fishing catch' },
            { src: '/images/boat-1.jpg', alt: lang === 'zh' ? 'Kingfisher 3025 专业海钓船' : 'Kingfisher 3025 fishing boat' },
            { src: '/images/catch-2.jpg', alt: lang === 'zh' ? '温哥华比目鱼海钓' : 'Vancouver halibut fishing' },
            { src: '/images/boat-2.jpg', alt: lang === 'zh' ? 'Axopar 37 豪华海钓艇' : 'Axopar 37 luxury fishing vessel' },
          ].map((img, i) => (
            <div key={i} className="aspect-[4/3] rounded-2xl overflow-hidden">
              <img
                src={img.src}
                alt={img.alt}
                className="w-full h-full object-cover hover:scale-105 transition-transform duration-700"
              />
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
