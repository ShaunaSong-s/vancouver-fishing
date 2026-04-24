import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        // Deep teal — primary brand color
        sea: {
          50: '#edfcfa',
          100: '#d2f7f3',
          200: '#a9efe8',
          300: '#72e1d8',
          400: '#3ec9c1',
          500: '#22ada7',
          600: '#198b88',
          700: '#186f6e',
          800: '#185959',
          900: '#194a4a',
          950: '#082e2f',
        },
        // Warm coral accent
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
        // Neutral slate for backgrounds
        drift: {
          50: '#f8fafb',
          100: '#f0f4f6',
          200: '#e4eaed',
          300: '#cdd6dc',
          400: '#9eadb8',
          500: '#758796',
          600: '#5d6f7d',
          700: '#4b5a66',
          800: '#414d56',
          900: '#39434a',
          950: '#1c2429',
        },
      },
      fontFamily: {
        heading: ['"Inter"', 'system-ui', 'sans-serif'],
        body: ['"Inter"', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
      },
    },
  },
  plugins: [],
};

export default config;
