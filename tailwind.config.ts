import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        // Deep ocean navy — page background (matches mini-program)
        sea: {
          50: '#e0f4fc',
          100: '#b8e4f5',
          200: '#7ec8e3',
          300: '#4fa8c9',
          400: '#2d7fa3',
          500: '#1a5a7a',
          600: '#134560',
          700: '#0d2f45',
          800: '#0d1f3c',
          900: '#0a1628',
          950: '#060e1a',
        },
        // Warm gold accent (matches mini-program primary)
        gold: {
          50: '#fdf8ed',
          100: '#f5eed9',
          200: '#ecdcb3',
          300: '#e8d5a3',
          400: '#dfc08a',
          500: '#c9a96e',
          600: '#b8945a',
          700: '#9a7a48',
          800: '#7d6238',
          900: '#5e4a2b',
        },
        // Keep coral for CTA/highlights
        coral: {
          50: '#fff4f1',
          100: '#ffe7e0',
          200: '#ffd3c6',
          300: '#ffb39e',
          400: '#ff8566',
          500: '#f75f3b',
          600: '#e4441d',
          700: '#c03514',
          800: '#9e2f14',
          900: '#832c18',
        },
        // Dark neutrals for cards/text
        drift: {
          50: '#f8fafb',
          100: '#e8ecf0',
          200: '#c8d1d9',
          300: '#9eadb8',
          400: '#758796',
          500: '#5d6f7d',
          600: '#4b5a66',
          700: '#39434a',
          800: '#1c2429',
          900: '#121820',
          950: '#0a0f14',
        },
      },
      fontFamily: {
        heading: ['var(--font-inter)', 'system-ui', 'sans-serif'],
        body: ['var(--font-inter)', 'var(--font-noto-sc)', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
        mono: ['SF Mono', 'Fira Code', 'monospace'],
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
      },
      keyframes: {
        'fade-in-up': {
          '0%': { opacity: '0', transform: 'translateY(16px) scale(0.97)' },
          '100%': { opacity: '1', transform: 'translateY(0) scale(1)' },
        },
        'slide-in-right': {
          '0%': { transform: 'translateX(100%)' },
          '100%': { transform: 'translateX(0)' },
        },
      },
      animation: {
        'fade-in-up': 'fade-in-up 0.25s ease-out',
        'slide-in-right': 'slide-in-right 0.3s ease-out',
      },
    },
  },
  plugins: [],
};

export default config;
