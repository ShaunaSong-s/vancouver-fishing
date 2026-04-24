import type { Metadata } from 'next';
import { LanguageProvider } from '@/i18n/LanguageContext';
import './globals.css';

export const metadata: Metadata = {
  metadataBase: new URL('https://topfishingcharter.ca'),
  title: {
    default: 'Top Vancouver Fishing Charter | 温哥华海钓包船 | 温哥华海尚海钓',
    template: '%s | Top Vancouver Fishing Charter',
  },
  description: 'Top Vancouver Fishing Charter — #1 Vancouver deep sea fishing charter service. Kingfisher 3025 & Axopar 37, bilingual Chinese/English captains, Steveston departure. Book salmon, halibut & crab fishing trips. 温哥华海尚海钓，温哥华最专业海钓包船服务，中英文船长，列治文渔人码头出发，三文鱼、比目鱼、螃蟹海钓之旅。',
  keywords: [
    'Vancouver fishing charter', 'Vancouver deep sea fishing', 'top vancouver fishing charter',
    'fishing charter Vancouver BC', 'salmon fishing Vancouver', 'halibut fishing Vancouver',
    'crab fishing Vancouver', 'Steveston fishing charter', 'Richmond fishing charter',
    'Vancouver boat charter', 'private fishing charter Vancouver', 'shared fishing trip Vancouver',
    'Chinese fishing charter Vancouver', 'bilingual fishing charter',
    'Kingfisher 3025', 'Axopar 37', 'Vancouver sport fishing',
    '温哥华海钓', '温哥华钓鱼', '温哥华海钓包船', '温哥华海尚海钓', '海尚海钓',
    '温哥华深海钓鱼', '温哥华钓三文鱼', '温哥华钓比目鱼', '温哥华钓螃蟹',
    '列治文海钓', '温哥华包船出海', '温哥华拼船海钓', '温哥华华人海钓',
  ],
  alternates: {
    canonical: 'https://topfishingcharter.ca',
  },
  openGraph: {
    title: 'Top Vancouver Fishing Charter | 温哥华海钓包船',
    description: '#1 Vancouver deep sea fishing charter. Two premium boats, bilingual Chinese/English service. 温哥华最专业海钓包船，中英文服务。',
    type: 'website',
    url: 'https://topfishingcharter.ca',
    siteName: 'Top Vancouver Fishing Charter',
    locale: 'zh_CN',
    alternateLocale: 'en_CA',
    images: [{ url: '/images/hero-1.jpg', width: 1920, height: 960, alt: 'Vancouver Fishing Charter' }],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Top Vancouver Fishing Charter | 温哥华海钓包船',
    description: '#1 Vancouver deep sea fishing charter — Book now!',
    images: ['/images/hero-1.jpg'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: { index: true, follow: true, 'max-image-preview': 'large' },
  },
  verification: {},
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="zh" suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin="anonymous"
        />
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="theme-color" content="#082e2f" />
      </head>
      <body className="bg-drift-50 text-drift-950 antialiased font-body">
        <LanguageProvider>{children}</LanguageProvider>
      </body>
    </html>
  );
}
