import Header from '@/components/Header';
import Hero from '@/components/Hero';
import About from '@/components/About';
import Boats from '@/components/Boats';
import BookingForm from '@/components/BookingForm';
import Location from '@/components/Location';
import Policy from '@/components/Policy';
import Footer from '@/components/Footer';

export default function Home() {
  return (
    <main>
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
