import type { Metadata } from 'next';
import { LanguageProvider } from '@/i18n/LanguageContext';
import './globals.css';

export const metadata: Metadata = {
  title: 'Top Vancouver Fishing Charter | 温哥华海尚海钓',
  description: 'Top Vancouver Fishing Charter — Professional deep sea fishing charters in Vancouver. Two premium boats, bilingual service. 温哥华海尚海钓，专业海钓包船服务，中英文服务。',
  keywords: 'Vancouver fishing, deep sea fishing, fishing charter, top vancouver fishing charter, 温哥华海尚海钓, 海尚海钓, 包船, 钓鱼, Richmond, Steveston',
  openGraph: {
    title: 'Top Vancouver Fishing Charter | 温哥华海尚海钓',
    description: 'Top Vancouver Fishing Charter — Professional deep sea fishing charters in Vancouver',
    type: 'website',
    locale: 'zh_CN',
    alternateLocale: 'en_CA',
  },
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
