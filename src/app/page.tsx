import Header from '@/components/Header';
import Hero from '@/components/Hero';
import About from '@/components/About';
import Boats from '@/components/Boats';
import FishingGuide from '@/components/FishingGuide';
import BookingForm from '@/components/BookingForm';
import Location from '@/components/Location';
import Policy from '@/components/Policy';
import Footer from '@/components/Footer';
import FloatingCTA from '@/components/FloatingCTA';

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'TouristAttraction',
  name: 'Top Vancouver Fishing Charter',
  alternateName: '温哥华海尚海钓',
  description: 'Professional deep sea fishing charters in Vancouver, BC. Salmon, halibut, lingcod, and crab fishing trips departing from Imperial Landing Docks. Private charters and shared trips available.',
  url: 'https://topfishingcharter.ca',
  address: {
    '@type': 'PostalAddress',
    streetAddress: '4310 Bayview Street',
    addressLocality: 'Richmond',
    addressRegion: 'BC',
    addressCountry: 'CA',
    postalCode: 'V7E 3S3',
  },
  geo: {
    '@type': 'GeoCoordinates',
    latitude: 49.12542,
    longitude: -123.18476,
  },
  image: ['https://topfishingcharter.ca/images/hero-1.jpg', 'https://topfishingcharter.ca/images/hero-2.jpg'],
  priceRange: '$240 - $2200 CAD',
  openingHoursSpecification: {
    '@type': 'OpeningHoursSpecification',
    dayOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    opens: '05:00',
    closes: '20:00',
  },
  availableLanguage: [
    { '@type': 'Language', name: 'Chinese', alternateName: 'zh' },
    { '@type': 'Language', name: 'English', alternateName: 'en' },
  ],
  makesOffer: [
    {
      '@type': 'Offer',
      name: 'Kingfisher 3025 Private Charter',
      description: '30ft professional aluminum fishing boat with 500HP Yamaha, up to 8 guests. Includes all gear, bait, life jackets, GPS fish finder.',
      price: '1700',
      priceCurrency: 'CAD',
    },
    {
      '@type': 'Offer',
      name: 'Axopar 37 XC Private Charter',
      description: '37ft Finnish luxury sport boat with heated cabin, up to 10 guests. Includes all gear, bait, life jackets, GPS fish finder.',
      price: '2200',
      priceCurrency: 'CAD',
    },
    {
      '@type': 'Offer',
      name: 'Shared Fishing Trip',
      description: 'Join a shared fishing trip from Imperial Landing Docks. Full day deep sea fishing with professional captain.',
      price: '240',
      priceCurrency: 'CAD',
    },
  ],
  aggregateRating: {
    '@type': 'AggregateRating',
    ratingValue: '4.9',
    reviewCount: '86',
    bestRating: '5',
  },
};

const faqJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'FAQPage',
  mainEntity: [
    {
      '@type': 'Question',
      name: 'What is included in a Vancouver fishing charter trip?',
      acceptedAnswer: {
        '@type': 'Answer',
        text: 'Every trip includes complete professional fishing gear, life jackets, bait, GPS fish finder, private washroom, commercial insurance, and seasick pills. You just need to bring lunch, sunscreen, and a printed fishing license.',
      },
    },
    {
      '@type': 'Question',
      name: 'Do I need a fishing license for Vancouver fishing?',
      acceptedAnswer: {
        '@type': 'Answer',
        text: 'Yes, BC law requires all anglers (including under 16) to have a valid Tidal Waters Sport Fishing License. You can apply online at the DFO website. A printed paper copy is mandatory — digital screenshots are not accepted.',
      },
    },
    {
      '@type': 'Question',
      name: 'What fish can I catch in Vancouver waters?',
      acceptedAnswer: {
        '@type': 'Answer',
        text: 'Vancouver offers year-round fishing: Salmon (June-October), Halibut (April-August), Lingcod and Rockfish (May-September), Dungeness Crab (year-round), and Spot Prawns (May-July). Peak salmon season is July-September.',
      },
    },
    {
      '@type': 'Question',
      name: 'What is the cancellation policy?',
      acceptedAnswer: {
        '@type': 'Answer',
        text: 'Free cancellation with 72+ hours notice. Weather-related cancellations by the captain are free to reschedule. Cancellations within 72 hours are non-refundable, but one free reschedule is offered.',
      },
    },
    {
      '@type': 'Question',
      name: 'Where does the fishing charter depart from?',
      acceptedAnswer: {
        '@type': 'Answer',
        text: 'All trips depart from Imperial Landing Docks at 4310 Bayview Street, Richmond, BC. Free parking is available nearby. Please arrive 5-15 minutes before departure time (typically 8:00 AM).',
      },
    },
    {
      '@type': 'Question',
      name: 'How long is a typical fishing trip?',
      acceptedAnswer: {
        '@type': 'Answer',
        text: 'A standard full-day trip is approximately 9-9.5 hours (8:00 AM to 5:00 PM). This includes transit to fishing grounds, active fishing time, lunch break, and return to dock.',
      },
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
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqJsonLd) }}
      />
      <Header />
      <Hero />
      <About />
      <Boats />
      <FishingGuide />
      <BookingForm />
      <Location />
      <Policy />
      <Footer />
      <FloatingCTA />
    </main>
  );
}
