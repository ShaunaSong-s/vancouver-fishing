'use client';

import { useLanguage } from '@/i18n/LanguageContext';
import { BOATS } from '@/lib/types';
import Image from 'next/image';
import AnimateOnScroll from './AnimateOnScroll';

export default function Boats() {
  const { t } = useLanguage();

  const boatConfigs = [
    { id: 'kingfisher' as const, data: BOATS.kingfisher, tKey: t.boats.kingfisher, img: '/images/kingfisher.jpg' },
    { id: 'axpor' as const, data: BOATS.axpor, tKey: t.boats.axpor, img: '/images/axopar.jpg' },
  ];

  const scrollToBooking = (boatId: string) => {
    document.querySelector('#booking')?.scrollIntoView({ behavior: 'smooth' });
    setTimeout(() => {
      const select = document.querySelector('#boat-select') as HTMLSelectElement;
      if (select) {
        select.value = boatId;
        select.dispatchEvent(new Event('change', { bubbles: true }));
      }
    }, 500);
  };

  return (
    <section id="boats" className="py-24">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <span className="text-gold-400 text-sm font-semibold tracking-wider uppercase">{t.sections?.fleet || 'Our Fleet'}</span>
          <h2 className="text-3xl md:text-4xl font-heading font-extrabold text-white mt-3 mb-4">
            {t.boats.title}
          </h2>
          <p className="text-white/60 text-base max-w-xl mx-auto">{t.boats.subtitle}</p>
          <div className="w-12 h-1 bg-gradient-to-r from-gold-400 to-gold-500 mx-auto rounded-full mt-4" />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-8">
          {boatConfigs.map(({ id, data, tKey, img }, i) => (
            <AnimateOnScroll key={id} delay={i * 150}>
            <div
              className="group glass rounded-3xl overflow-hidden hover:border-gold-400/25 hover:shadow-2xl hover:shadow-gold-400/5 transition-all duration-500"
            >
              {/* Image */}
              <div className="relative h-56 sm:h-64 overflow-hidden">
                <Image
                  src={img}
                  alt={tKey.name}
                  fill
                  className="object-cover group-hover:scale-105 transition-transform duration-700"
                  sizes="(max-width: 1024px) 100vw, 50vw"
                  quality={80}
                />
                <div className="absolute inset-0 bg-gradient-to-t from-sea-900/60 to-transparent" />
                <div className="absolute top-4 left-4 bg-gold-400/90 backdrop-blur-sm text-sea-900 font-bold text-xs px-3 py-1.5 rounded-lg">
                  {data.length} ft
                </div>
                <div className="absolute bottom-4 left-4 right-4">
                  <h3 className="text-2xl font-heading font-bold text-white drop-shadow-lg">
                    {tKey.name}
                  </h3>
                </div>
              </div>

              {/* Content */}
              <div className="p-6">
                <p className="text-white/60 text-sm mb-5 leading-relaxed">{tKey.desc}</p>

                {/* Features */}
                <div className="flex flex-wrap gap-2 mb-6">
                  {tKey.features.map((feature, i) => (
                    <span
                      key={i}
                      className="text-xs font-medium text-gold-500 bg-gold-500/10 border border-gold-500/15 rounded-lg px-2.5 py-1.5"
                    >
                      {feature}
                    </span>
                  ))}
                </div>

                {/* Pricing */}
                <div className="flex gap-3 mb-6">
                  <div className="flex-1 bg-white/5 rounded-xl p-4 border border-gold-400/10 text-center">
                    <div className="text-[11px] text-white/40 uppercase tracking-wide font-semibold mb-1">{t.boats.charter}</div>
                    <div className="text-xl font-extrabold text-gold-400">${data.charterPrice.toLocaleString()}</div>
                    <div className="text-[11px] text-white/40">{t.boats.priceUnit}</div>
                  </div>
                  <div className="flex-1 bg-white/5 rounded-xl p-4 border border-gold-400/10 text-center">
                    <div className="text-[11px] text-white/40 uppercase tracking-wide font-semibold mb-1">{t.boats.perPerson}</div>
                    <div className="text-xl font-extrabold text-gold-400">${data.perPersonPrice}</div>
                    <div className="text-[11px] text-white/40">{t.boats.priceUnit}</div>
                  </div>
                </div>

                <button
                  onClick={() => scrollToBooking(id)}
                  className="w-full btn-gold py-3.5 rounded-xl transition-all text-sm"
                >
                  {t.boats.selectBoat}
                </button>
              </div>
            </div>
            </AnimateOnScroll>
          ))}
        </div>
      </div>
    </section>
  );
}
