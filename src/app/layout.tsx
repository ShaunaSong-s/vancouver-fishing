import type { Metadata } from 'next';
import { Inter, Noto_Sans_SC } from 'next/font/google';
import { LanguageProvider } from '@/i18n/LanguageContext';
import { MemberProvider } from '@/lib/MemberContext';
import './globals.css';

const inter = Inter({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700', '800', '900'],
  variable: '--font-inter',
  display: 'swap',
});

const notoSansSC = Noto_Sans_SC({
  subsets: ['latin'],
  weight: ['400', '500', '700'],
  variable: '--font-noto-sc',
  display: 'swap',
});

export const metadata: Metadata = {
  metadataBase: new URL('https://topfishingcharter.ca'),
  title: {
    default: 'Top Vancouver Fishing Charter | 温哥华海钓包船 | 温哥华海尚海钓',
    template: '%s | Top Vancouver Fishing Charter',
  },
  description: 'Top Vancouver Fishing Charter — #1 Vancouver deep sea fishing charter. Kingfisher 3025 & Axopar 37 XC, bilingual Chinese/English captains, Imperial Landing Docks departure. Book salmon, halibut, lingcod & crab fishing trips. All gear included. 温哥华海尚海铓，最专业海铓包船，中英文船长，Imperial Landing Docks出发，三文鱼、比目鱼、鳕鱼、蟃蟹海铓。',
  keywords: [
    'Vancouver fishing charter', 'Vancouver deep sea fishing', 'top vancouver fishing charter',
    'fishing charter Vancouver BC', 'salmon fishing Vancouver', 'halibut fishing Vancouver',
    'crab fishing Vancouver', 'Imperial Landing Docks fishing charter', 'Richmond fishing charter',
    'Vancouver boat charter', 'private fishing charter Vancouver', 'shared fishing trip Vancouver',
    'Chinese fishing charter Vancouver', 'bilingual fishing charter',
    'Kingfisher 3025', 'Axopar 37', 'Vancouver sport fishing',
    'lingcod fishing Vancouver', 'rockfish Vancouver', 'prawn fishing Vancouver',
    'Vancouver fishing trip price', 'Vancouver fishing charter cost', 'best fishing charter Vancouver',
    'fishing charter near me', 'BC fishing license', 'Vancouver fishing guide',
    'Vancouver fishing seasons', 'what to bring fishing Vancouver',
    '温哥华海钓', '温哥华钓鱼', '温哥华海钓包船', '温哥华海尚海钓', '海尚海钓',
    '温哥华深海钓鱼', '温哥华钓三文鱼', '温哥华钓比目鱼', '温哥华钓螃蟹',
    '列治文海钓', '温哥华包船出海', '温哥华拼船海钓', '温哥华华人海钓',
    '温哥华钓鳕鱼', '温哥华海钓攻略', '温哥华海钓价格', '温哥华海钓多少钱',
    '温哥华钓鱼证', '温哥华海钓季节', 'BC海钓',
  ],
  alternates: {
    canonical: 'https://topfishingcharter.ca',
  },
  openGraph: {
    title: 'Top Vancouver Fishing Charter | 温哥华海钓包船 | Salmon · Halibut · Crab',
    description: '#1 Vancouver deep sea fishing charter. Two premium boats (Kingfisher 3025 & Axopar 37), bilingual Chinese/English captains, all gear included. From $240/person. 温哥华最专业海钓包船，中英文服务，全套装备，$240起。',
    type: 'website',
    url: 'https://topfishingcharter.ca',
    siteName: 'Top Vancouver Fishing Charter',
    locale: 'zh_CN',
    alternateLocale: 'en_CA',
    images: [{ url: '/images/hero-1.jpg', width: 1920, height: 960, alt: 'Vancouver deep sea fishing charter - salmon fishing on the Pacific' }],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Top Vancouver Fishing Charter | Book from $240/person',
    description: 'Professional deep sea fishing in Vancouver. Salmon, halibut, crab. Two premium boats, bilingual service. 温哥华海钓包船',
    images: ['/images/hero-1.jpg'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: { index: true, follow: true, 'max-image-preview': 'large', 'max-snippet': -1 },
  },
  verification: {},
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="zh" suppressHydrationWarning className={`${inter.variable} ${notoSansSC.variable}`}>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="theme-color" content="#0a1628" />
      </head>
      <body className="bg-sea-900 text-white antialiased font-body">
        <LanguageProvider>
          <MemberProvider>{children}</MemberProvider>
        </LanguageProvider>
      </body>
    </html>
  );
}
