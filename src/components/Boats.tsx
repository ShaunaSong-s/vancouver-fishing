'use client';

import { useLanguage } from '@/i18n/LanguageContext';
import { BOATS } from '@/lib/types';

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
    <section id="boats" className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <span className="text-sea-600 text-sm font-semibold tracking-wider uppercase">{t.sections?.fleet || 'Our Fleet'}</span>
          <h2 className="text-3xl md:text-4xl font-heading font-extrabold text-drift-950 mt-3 mb-4">
            {t.boats.title}
          </h2>
          <p className="text-drift-500 text-base max-w-xl mx-auto">{t.boats.subtitle}</p>
          <div className="w-12 h-1 bg-gradient-to-r from-sea-500 to-coral-400 mx-auto rounded-full mt-4" />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-8">
          {boatConfigs.map(({ id, data, tKey, img }) => (
            <div
              key={id}
              className="group bg-drift-50 rounded-3xl overflow-hidden border border-drift-100 hover:border-sea-200 hover:shadow-2xl hover:shadow-sea-500/5 transition-all duration-500"
            >
              {/* Image */}
              <div className="relative h-56 sm:h-64 overflow-hidden">
                <img
                  src={img}
                  alt={tKey.name}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-drift-950/40 to-transparent" />
                <div className="absolute top-4 left-4 bg-white/90 backdrop-blur-sm text-sea-800 font-bold text-xs px-3 py-1.5 rounded-lg">
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
                <p className="text-drift-500 text-sm mb-5 leading-relaxed">{tKey.desc}</p>

                {/* Features */}
                <div className="flex flex-wrap gap-2 mb-6">
                  {tKey.features.map((feature, i) => (
                    <span
                      key={i}
                      className="text-xs font-medium text-sea-700 bg-sea-50 border border-sea-100 rounded-lg px-2.5 py-1.5"
                    >
                      {feature}
                    </span>
                  ))}
                </div>

                {/* Pricing */}
                <div className="flex gap-3 mb-6">
                  <div className="flex-1 bg-white rounded-xl p-4 border border-drift-100 text-center">
                    <div className="text-[11px] text-drift-400 uppercase tracking-wide font-semibold mb-1">{t.boats.charter}</div>
                    <div className="text-xl font-extrabold text-drift-900">${data.charterPrice.toLocaleString()}</div>
                    <div className="text-[11px] text-drift-400">{t.boats.priceUnit}</div>
                  </div>
                  <div className="flex-1 bg-white rounded-xl p-4 border border-drift-100 text-center">
                    <div className="text-[11px] text-drift-400 uppercase tracking-wide font-semibold mb-1">{t.boats.perPerson}</div>
                    <div className="text-xl font-extrabold text-drift-900">${data.perPersonPrice}</div>
                    <div className="text-[11px] text-drift-400">{t.boats.priceUnit}</div>
                  </div>
                </div>

                <button
                  onClick={() => scrollToBooking(id)}
                  className="w-full bg-sea-600 hover:bg-sea-700 text-white font-semibold py-3.5 rounded-xl transition-all hover:shadow-lg hover:shadow-sea-600/20 text-sm"
                >
                  {t.boats.selectBoat}
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
