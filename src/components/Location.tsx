'use client';

import { useLanguage } from '@/i18n/LanguageContext';

export default function Location() {
  const { t } = useLanguage();

  return (
    <section id="location" className="py-24 bg-drift-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-14">
          <span className="text-sea-600 text-sm font-semibold tracking-wider uppercase">Location</span>
          <h2 className="text-3xl md:text-4xl font-heading font-extrabold text-drift-950 mt-3 mb-4">
            {t.location.title}
          </h2>
          <p className="text-drift-500 text-base max-w-lg mx-auto">{t.location.subtitle}</p>
          <div className="w-12 h-1 bg-gradient-to-r from-sea-500 to-coral-400 mx-auto rounded-full mt-4" />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
          {/* Map */}
          <div className="lg:col-span-3 rounded-3xl overflow-hidden shadow-lg shadow-drift-200/50 border border-drift-100">
            <iframe
              src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2617.674204692085!2d-123.18476!3d49.12542!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x5486100c2ea5e4e3%3A0x3f3b1ae6c5bf20e9!2sSteveston%20Fisherman&#39;s%20Wharf!5e0!3m2!1sen!2sca!4v1700000000000!5m2!1sen!2sca"
              width="100%"
              height="380"
              style={{ border: 0 }}
              allowFullScreen
              loading="lazy"
              referrerPolicy="no-referrer-when-downgrade"
              title="Steveston Wharf Map"
            />
          </div>

          {/* Info cards */}
          <div className="lg:col-span-2 flex flex-col gap-4">
            {/* Address */}
            <div className="bg-white rounded-2xl p-6 border border-drift-100 flex-1">
              <div className="w-10 h-10 rounded-xl bg-sea-50 text-sea-600 flex items-center justify-center mb-4">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z" />
                  <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1115 0z" />
                </svg>
              </div>
              <h3 className="text-sm font-bold text-drift-900 mb-1">{t.location.address}</h3>
              <p className="text-drift-500 text-sm mb-4">{t.location.fullAddress}</p>
              <a
                href="https://maps.google.com/?q=Steveston+Fisherman's+Wharf+Richmond+BC"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 text-sea-600 hover:text-sea-700 text-sm font-semibold transition-colors"
              >
                {t.location.directions}
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" />
                </svg>
              </a>
            </div>

            {/* Parking */}
            <div className="bg-white rounded-2xl p-6 border border-drift-100">
              <div className="w-10 h-10 rounded-xl bg-sea-50 text-sea-600 flex items-center justify-center mb-4">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M8.25 18.75a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 01-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 00-3.213-9.193 2.056 2.056 0 00-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 00-10.026 0 1.106 1.106 0 00-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12" />
                </svg>
              </div>
              <p className="text-drift-700 text-sm font-medium">{t.location.parking}</p>
            </div>

            {/* Early arrival */}
            <div className="bg-gradient-to-br from-sea-600 to-sea-700 rounded-2xl p-6 text-white">
              <div className="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center mb-4">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <p className="text-white/90 text-sm font-medium">{t.location.arriveEarly}</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
