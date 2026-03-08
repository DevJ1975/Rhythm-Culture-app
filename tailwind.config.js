/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/**/*.{html,ts,scss}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#0066FF',  // Electric blue
          50: '#EBF2FF',
          100: '#C2D9FF',
          200: '#99BFFF',
          300: '#70A5FF',
          400: '#478BFF',
          500: '#0066FF',
          600: '#0052CC',
          700: '#003D99',
          800: '#002966',
          900: '#001433',
        },
        dark: {
          DEFAULT: '#0A0A0A',
          100: '#1A1A1A',
          200: '#2A2A2A',
          300: '#3A3A3A',
          400: '#4A4A4A',
        },
        surface: {
          DEFAULT: '#111111',
          card: '#1A1A1A',
          input: '#222222',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['Inter', 'system-ui', 'sans-serif'],
      },
      borderRadius: {
        'xl': '1rem',
        '2xl': '1.5rem',
        '3xl': '2rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'pulse-glow': 'pulseGlow 2s infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        pulseGlow: {
          '0%, 100%': { boxShadow: '0 0 5px rgba(0, 102, 255, 0.5)' },
          '50%': { boxShadow: '0 0 20px rgba(0, 102, 255, 0.8)' },
        },
      },
    },
  },
  plugins: [],
  // Allow Tailwind classes to work alongside Ionic
  important: false,
  corePlugins: {
    preflight: false,
  },
};
