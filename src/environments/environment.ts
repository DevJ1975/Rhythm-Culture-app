// Development environment configuration
// Using Firebase Local Emulator Suite for local dev (no real Firebase project needed).
// The 'demo-' prefix tells the Firebase SDK to ONLY connect to local emulators.
// Replace these with your real Firebase config when ready.
export const environment = {
  production: false,
  demoCredentials: {
    email: 'demo@rhythmculture.app',
    password: 'Demo1234!',
  },
  firebase: {
    apiKey: 'demo-key',
    authDomain: 'demo-rhythm-culture.firebaseapp.com',
    projectId: 'demo-rhythm-culture',
    storageBucket: 'demo-rhythm-culture.appspot.com',
    messagingSenderId: '000000000000',
    appId: '1:000000000000:web:0000000000000000',
    measurementId: 'G-00000000',
  },
  useEmulators: true,
  appVersion: '1.0.0',
  samGov: {
    apiKey: 'demo-sam-key',
    baseUrl: 'https://api.sam.gov',
    useMockData: true,
  },
};
