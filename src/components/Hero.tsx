'use client';

import { useLanguage } from '@/i18n/LanguageContext';
import { useState, useEffect } from 'react';

const heroImages = ['/images/hero-1.jpg', '/images/hero-2.jpg', '/images/hero-3.jpg'];

export default function Hero() {
  const { t, lang } = useLanguage();
  const [currentImg, setCurrentImg] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => setCurrentImg(i => (i + 1) % heroImages.length), 5000);
    return () => clearInterval(timer);
  }, []);

  const scrollTo = (id: string) => {
    document.querySelector(id)?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <section id="home" className="relative min-h-screen flex items-center overflow-hidden">
      {/* Background images with crossfade */}
      {heroImages.map((src, i) => (
        <div
          key={src}
          className="absolute inset-0 bg-cover bg-center transition-opacity duration-[2000ms]"
          style={{
            backgroundImage: `url('${src}')`,
            opacity: i === currentImg ? 1 : 0,
          }}
        />
      ))}
      {/* Gradient overlay */}
      <div className="absolute inset-0 bg-gradient-to-r from-sea-950/85 via-sea-900/70 to-sea-950/50" />
      <div className="absolute inset-0 bg-gradient-to-t from-sea-950/60 via-transparent to-transparent" />

      {/* Decorative elements */}
      <div className="absolute top-20 right-10 w-72 h-72 bg-coral-500/10 rounded-full blur-3xl" />
      <div className="absolute bottom-20 left-10 w-96 h-96 bg-sea-400/10 rounded-full blur-3xl" />

      {/* Content */}
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-32">
        <div className="max-w-2xl">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm rounded-full px-4 py-1.5 mb-8 border border-white/10">
            <span className="w-1.5 h-1.5 bg-sea-400 rounded-full animate-pulse" />
            <span className="text-sea-200 text-xs font-medium tracking-wide">{t.hero.badge}</span>
          </div>

          <h1 className="text-4xl sm:text-5xl lg:text-6xl font-heading font-black text-white mb-6 leading-[1.1] tracking-tight">
            {lang === 'zh' ? (
              <>温哥华<span className="text-transparent bg-clip-text bg-gradient-to-r from-sea-300 to-sea-100">深海钓鱼</span></>
            ) : (
              <>Vancouver <span className="text-transparent bg-clip-text bg-gradient-to-r from-sea-300 to-sea-100">Deep Sea Fishing</span></>
            )}
          </h1>

          <p className="text-lg sm:text-xl text-white/70 mb-10 leading-relaxed max-w-xl">
            {t.hero.subtitle}
          </p>

          <div className="flex flex-col sm:flex-row gap-3">
            <button
              onClick={() => scrollTo('#booking')}
              className="bg-coral-500 hover:bg-coral-600 text-white font-bold text-base px-8 py-4 rounded-2xl transition-all hover:shadow-xl hover:shadow-coral-500/30 hover:-translate-y-0.5 glow-coral"
            >
              {t.hero.cta}
            </button>
            <button
              onClick={() => scrollTo('#boats')}
              className="bg-white/10 hover:bg-white/15 backdrop-blur-sm text-white font-semibold text-base px-8 py-4 rounded-2xl transition-all border border-white/15 hover:border-white/25"
            >
              {t.common.learnMore}
            </button>
          </div>

          {/* Stats row */}
          <div className="mt-16 flex gap-10">
            {[
              { val: '2', label: lang === 'zh' ? '专业船只' : 'Pro Boats' },
              { val: '10+', label: lang === 'zh' ? '年经验' : 'Years Exp.' },
              { val: '2000+', label: lang === 'zh' ? '满意客户' : 'Happy Clients' },
            ].map(({ val, label }) => (
              <div key={val}>
                <div className="text-2xl sm:text-3xl font-black text-white">{val}</div>
                <div className="text-white/40 text-xs mt-1 font-medium">{label}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Bottom gradient fade */}
      <div className="absolute bottom-0 left-0 right-0 h-24 bg-gradient-to-t from-drift-50 to-transparent" />
    </section>
  );
}
