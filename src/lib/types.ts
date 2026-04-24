export interface BoatInfo {
  id: 'kingfisher' | 'axpor';
  name: string;
  length: string;
  maxPassengers: number;
  charterPrice: number;
  perPersonPrice: number;
  image: string;
  features: string[];
}

export interface BookingFormData {
  boatId: 'kingfisher' | 'axpor';
  bookingType: 'charter' | 'shared';
  date: string;
  passengers: number;
  name: string;
  phone: string;
  email: string;
  wechat?: string;
  paymentMethod: 'wechat' | 'credit_card' | 'e_transfer';
  notes?: string;
}

export interface BookingResponse {
  success: boolean;
  bookingId?: string;
  message: string;
}

export const BOATS: Record<string, Omit<BoatInfo, 'name' | 'features'>> = {
  kingfisher: {
    id: 'kingfisher',
    length: '30',
    maxPassengers: 8,
    charterPrice: 1700,
    perPersonPrice: 240,
    image: '/images/kingfisher.jpg',
  },
  axpor: {
    id: 'axpor',
    length: '37',
    maxPassengers: 10,
    charterPrice: 2200,
    perPersonPrice: 240,
    image: '/images/axpor.jpg',
  },
};
