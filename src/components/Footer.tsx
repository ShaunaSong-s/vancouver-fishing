'use client';

import { useLanguage } from '@/i18n/LanguageContext';

export default function Footer() {
  const { t, lang } = useLanguage();

  const navItems = [
    { key: 'home', href: '#home' },
    { key: 'boats', href: '#boats' },
    { key: 'booking', href: '#booking' },
    { key: 'location', href: '#location' },
    { key: 'policy', href: '#policy' },
  ] as const;

  const scrollTo = (href: string) => {
    document.querySelector(href)?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <footer className="bg-sea-900 border-t border-gold-400/10 text-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Main footer */}
        <div className="py-14 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10">
          {/* Brand */}
          <div className="lg:col-span-1">
            <div className="flex items-center gap-2.5 mb-4">
              <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-gold-400 to-gold-500 flex items-center justify-center">
                <svg className="w-5 h-5 text-sea-900" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <div className="font-heading text-[15px] font-bold">{t.footer.company}</div>
                <div className="text-[10px] text-gold-400/60 font-medium tracking-wider uppercase">
                  {lang === 'zh' ? 'Top Vancouver Fishing Charter' : '温哥华海尚海钓'}
                </div>
              </div>
            </div>
            <p className="text-white/40 text-sm leading-relaxed">{t.footer.tagline}</p>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="text-xs font-semibold uppercase tracking-wider text-gold-400/70 mb-4">
              {t.footer.quickLinks}
            </h4>
            <ul className="space-y-2.5">
              {navItems.map(({ key, href }) => (
                <li key={key}>
                  <button
                    onClick={() => scrollTo(href)}
                    className="text-white/50 hover:text-gold-400 text-sm transition-colors"
                  >
                    {t.nav[key as keyof typeof t.nav]}
                  </button>
                </li>
              ))}
            </ul>
          </div>

          {/* Address */}
          <div>
            <h4 className="text-xs font-semibold uppercase tracking-wider text-gold-400/70 mb-4">
              {t.footer.followUs}
            </h4>
            <div className="flex items-start gap-3 mb-5">
              <svg className="w-4 h-4 text-gold-400/50 mt-0.5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z" />
                <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1115 0z" />
              </svg>
              <p className="text-white/50 text-sm leading-relaxed">{t.footer.address}</p>
            </div>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="border-t border-gold-400/10 py-5 flex flex-col sm:flex-row justify-between items-center gap-3">
          <p className="text-white/30 text-xs">{t.footer.rights}</p>
          <p className="text-white/30 text-xs">topfishingcharter.ca</p>
        </div>

        {/* SEO content — visible to search engines */}
        <div className="border-t border-gold-400/5 pt-6 pb-8 text-white/15 text-[11px] leading-relaxed max-w-4xl mx-auto">
          <h2 className="text-white/20 text-xs font-semibold mb-2">Vancouver Fishing Charter | 温哥华海钓包船</h2>
          <p>
            Top Vancouver Fishing Charter (温哥华海尚海铓) is Vancouver&apos;s premier deep sea fishing charter service based at Imperial Landing Docks in Richmond, BC.
            We offer private charter and shared fishing trips for salmon fishing, halibut fishing, and crab fishing in the waters around Vancouver, the Gulf Islands, and the Strait of Georgia.
            Our fleet includes the Kingfisher 3025 XRS (30ft, up to 8 guests) and Axopar 37 XC Cross Cabin (37ft, up to 10 guests), both equipped with Garmin GPS fish finders, private washrooms, and professional fishing gear.
            Our licensed captains hold SVOP, SDV-BS, and ROC-M certifications and provide bilingual Chinese and English service.
            Departing daily from Imperial Landing Docks, Richmond BC — the heart of Vancouver&apos;s fishing community.
          </p>
          <p className="mt-2">
            温哥华海尚海钓是温哥华地区最专业的海钓包船服务。我们从Richmond Imperial Landing Docks出发，提供三文鱼海钓、比目鱼海钓、螃蟹捕捞等多种海钓行程。
            两艘专业海钓船（Kingfisher 3025 和 Axopar 37），配备Garmin鱼探仪、独立卫生间、全套专业钓具。
            持牌船长团队持有SVOP、SDV-BS、ROC-M等专业证书，提供中英文双语服务。
            温哥华海钓、温哥华钓鱼、温哥华包船出海、温哥华华人海钓、列治文海钓首选。
          </p>
        </div>
      </div>
    </footer>
  );
}
