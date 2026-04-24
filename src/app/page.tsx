import Header from '@/components/Header';
import Hero from '@/components/Hero';
import About from '@/components/About';
import Boats from '@/components/Boats';
import BookingForm from '@/components/BookingForm';
import Location from '@/components/Location';
import Policy from '@/components/Policy';
import Footer from '@/components/Footer';

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'TouristAttraction',
  name: 'Top Vancouver Fishing Charter',
  alternateName: '温哥华海尚海钓',
  description: 'Professional deep sea fishing charters in Vancouver, BC. Salmon, halibut, and crab fishing trips departing from Steveston Fisherman\'s Wharf.',
  url: 'https://topfishingcharter.ca',
  telephone: '+1-672-965-7666',
  email: 'info@topfishingcharter.ca',
  address: {
    '@type': 'PostalAddress',
    streetAddress: 'Steveston Fisherman\'s Wharf, Dock #2',
    addressLocality: 'Richmond',
    addressRegion: 'BC',
    addressCountry: 'CA',
  },
  geo: {
    '@type': 'GeoCoordinates',
    latitude: 49.12542,
    longitude: -123.18476,
  },
  image: 'https://topfishingcharter.ca/images/hero-1.jpg',
  priceRange: '$240 - $2200 CAD',
  openingHoursSpecification: {
    '@type': 'OpeningHoursSpecification',
    dayOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    opens: '05:00',
    closes: '20:00',
  },
  availableLanguage: [
    { '@type': 'Language', name: 'Chinese' },
    { '@type': 'Language', name: 'English' },
  ],
  makesOffer: [
    {
      '@type': 'Offer',
      name: 'Kingfisher 3025 Private Charter',
      description: '30ft professional fishing boat, up to 8 guests',
      price: '1700',
      priceCurrency: 'CAD',
    },
    {
      '@type': 'Offer',
      name: 'Axopar 37 Private Charter',
      description: '37ft luxury fishing vessel, up to 10 guests',
      price: '2200',
      priceCurrency: 'CAD',
    },
    {
      '@type': 'Offer',
      name: 'Shared Fishing Trip',
      description: 'Join a shared fishing trip, per person pricing',
      price: '240',
      priceCurrency: 'CAD',
    },
  ],
};

export default function Home() {
  return (
    <main>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <Header />
      <Hero />
      <About />
      <Boats />
      <BookingForm />
      <Location />
      <Policy />
      <Footer />
    </main>
  );
}
