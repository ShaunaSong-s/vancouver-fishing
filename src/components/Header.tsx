'use client';

import { useLanguage } from '@/i18n/LanguageContext';
import { useState, useEffect } from 'react';

export default function Header() {
  const { lang, setLang, t } = useLanguage();
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 50);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  const navItems = [
    { key: 'home', href: '#home' },
    { key: 'boats', href: '#boats' },
    { key: 'booking', href: '#booking' },
    { key: 'location', href: '#location' },
    { key: 'policy', href: '#policy' },
  ] as const;

  const handleNav = (href: string) => {
    setMobileOpen(false);
    document.querySelector(href)?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${
        scrolled
          ? 'bg-white/90 backdrop-blur-xl shadow-sm border-b border-drift-200/50'
          : 'bg-transparent'
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16 lg:h-[72px]">
          {/* Logo */}
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-sea-500 to-sea-700 flex items-center justify-center shadow-sm">
              <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div className="flex flex-col">
              <span className={`font-heading text-[15px] font-bold tracking-tight leading-tight ${scrolled ? 'text-sea-900' : 'text-white'}`}>
                {lang === 'zh' ? '海尚海钓' : 'Top Fishing'}
              </span>
              <span className={`text-[10px] font-medium tracking-wider uppercase leading-tight ${scrolled ? 'text-drift-400' : 'text-white/60'}`}>
                Vancouver Charter
              </span>
            </div>
          </div>

          {/* Desktop Nav */}
          <nav className="hidden lg:flex items-center gap-1">
            {navItems.map(({ key, href }) => (
              <button
                key={key}
                onClick={() => handleNav(href)}
                className={`px-4 py-2 rounded-lg text-[13px] font-medium transition-all ${
                  scrolled
                    ? 'text-drift-600 hover:text-sea-700 hover:bg-sea-50'
                    : 'text-white/80 hover:text-white hover:bg-white/10'
                }`}
              >
                {t.nav[key as keyof typeof t.nav]}
              </button>
            ))}
          </nav>

          {/* Right side */}
          <div className="flex items-center gap-3">
            <button
              onClick={() => setLang(lang === 'zh' ? 'en' : 'zh')}
              className={`text-xs font-semibold px-3 py-1.5 rounded-lg transition-all ${
                scrolled
                  ? 'text-drift-500 hover:text-sea-700 border border-drift-200 hover:border-sea-300 hover:bg-sea-50'
                  : 'text-white/70 hover:text-white border border-white/20 hover:border-white/40'
              }`}
            >
              {lang === 'zh' ? 'EN' : '中文'}
            </button>

            <button
              onClick={() => handleNav('#booking')}
              className="hidden sm:block bg-coral-500 hover:bg-coral-600 text-white font-semibold text-sm px-5 py-2.5 rounded-xl transition-all hover:shadow-lg hover:shadow-coral-500/25 hover:-translate-y-px"
            >
              {t.nav.booking}
            </button>

            <button
              onClick={() => setMobileOpen(!mobileOpen)}
              className="lg:hidden p-1.5"
              aria-label="Menu"
            >
              <svg className={`w-6 h-6 ${scrolled ? 'text-drift-700' : 'text-white'}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                {mobileOpen ? (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                ) : (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                )}
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Mobile menu */}
      {mobileOpen && (
        <div className="lg:hidden bg-white/95 backdrop-blur-xl border-t border-drift-100">
          <div className="px-4 py-3 space-y-1">
            {navItems.map(({ key, href }) => (
              <button
                key={key}
                onClick={() => handleNav(href)}
                className="block w-full text-left text-drift-700 hover:text-sea-700 py-2.5 px-4 rounded-xl hover:bg-sea-50 transition-colors text-sm font-medium"
              >
                {t.nav[key as keyof typeof t.nav]}
              </button>
            ))}
            <button
              onClick={() => handleNav('#booking')}
              className="block w-full bg-coral-500 text-white font-semibold text-center py-3 rounded-xl mt-2"
            >
              {t.nav.booking}
            </button>
          </div>
        </div>
      )}
    </header>
  );
}
