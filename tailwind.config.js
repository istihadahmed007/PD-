/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'dhaka-gold': '#F59E0B',
        'dhaka-green': '#10B981',
        'dhaka-cng': '#059669',
        'dhaka-red': '#EF4444',
        'dhaka-navy': '#0F172A',
      },
      fontFamily: {
        bengali: ['Noto Sans Bengali', 'sans-serif'],
      }
    },
  },
  plugins: [],
}
