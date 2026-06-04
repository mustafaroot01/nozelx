/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f5f7ff',
          100: '#ebf0ff',
          200: '#d6e0ff',
          300: '#b3c7ff',
          400: '#85a3ff',
          500: '#5275ff',
          600: '#2b47fc',
          700: '#1b2fe4',
          800: '#1727b9',
          900: '#192793',
          950: '#0f1457',
        },
        dark: {
          50: '#f6f6f7',
          100: '#eef0f2',
          200: '#dadde3',
          300: '#b8bdca',
          400: '#9097aa',
          500: '#717a90',
          600: '#596176',
          700: '#494e5f',
          800: '#3f424f',
          900: '#1a1b23',
          950: '#0e0f13',
        }
      },
      fontFamily: {
        cairo: ['Cairo', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
