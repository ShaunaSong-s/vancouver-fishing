'use client';

import { useLanguage } from '@/i18n/LanguageContext';
import { useState, useEffect } from 'react';
import Image from 'next/image';

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
          className={`absolute inset-0 transition-opacity duration-[2000ms] ${i === currentImg ? 'opacity-100' : 'opacity-0'}`}
        >
          <Image
            src={src}
            alt={`Vancouver fishing charter ${i + 1}`}
            fill
            className="object-cover"
            priority={i === 0}
            sizes="100vw"
            quality={85}
          />
        </div>
      ))}
      {/* Gradient overlay */}
      <div className="absolute inset-0 bg-gradient-to-b from-sea-900/10 via-sea-900/30 to-sea-900/85" />
      <div className="absolute inset-0 bg-gradient-to-r from-sea-900/60 via-transparent to-sea-900/40" />

      {/* Decorative elements */}
      <div className="absolute top-20 right-10 w-72 h-72 bg-gold-400/10 rounded-full blur-3xl" />
      <div className="absolute bottom-20 left-10 w-96 h-96 bg-gold-500/5 rounded-full blur-3xl" />

      {/* Content */}
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-32">
        <div className="max-w-2xl">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 bg-white/5 backdrop-blur-sm rounded-full px-4 py-1.5 mb-8 border border-gold-400/20">
            <span className="w-1.5 h-1.5 bg-gold-400 rounded-full animate-pulse" />
            <span className="text-gold-400 text-xs font-medium tracking-wide">{t.hero.badge}</span>
          </div>

          <h1 className="text-4xl sm:text-5xl lg:text-[3.5rem] xl:text-6xl font-heading font-black text-white mb-6 leading-[1.08] tracking-tight text-shadow-hero">
            {lang === 'zh' ? (
              <>温哥华<span className="gradient-text">深海钓鱼</span></>
            ) : (
              <>Vancouver <span className="gradient-text">Deep Sea Fishing</span></>
            )}
          </h1>

          <p className="text-lg sm:text-xl text-white/70 mb-10 leading-relaxed max-w-xl">
            {t.hero.subtitle}
          </p>

          <div className="flex flex-col sm:flex-row gap-3">
            <button
              onClick={() => scrollTo('#booking')}
              className="btn-gold text-base px-8 py-4 rounded-2xl transition-all hover:-translate-y-0.5 glow-coral"
            >
              {t.hero.cta}
            </button>
            <button
              onClick={() => scrollTo('#boats')}
              className="bg-white/5 hover:bg-white/10 backdrop-blur-sm text-gold-400 font-semibold text-base px-8 py-4 rounded-2xl transition-all border border-gold-400/25 hover:border-gold-400/40"
            >
              {t.common.learnMore}
            </button>
          </div>

          {/* Stats row */}
          <div className="mt-16 flex gap-6 sm:gap-10">
            {[
              { val: '2', label: lang === 'zh' ? '专业船只' : 'Pro Boats' },
              { val: '10+', label: lang === 'zh' ? '年经验' : 'Years Exp.' },
              { val: '5000+', label: lang === 'zh' ? '满意客户' : 'Happy Clients' },
            ].map(({ val, label }) => (
              <div key={val}>
                <div className="text-2xl sm:text-3xl font-black text-gold-400">{val}</div>
                <div className="text-white/40 text-xs mt-1 font-medium">{label}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Bottom gradient fade */}
      <div className="absolute bottom-0 left-0 right-0 h-24 bg-gradient-to-t from-sea-900 to-transparent" />
    </section>
  );
}
