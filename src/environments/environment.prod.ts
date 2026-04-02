// Production environment configuration
export const environment = {
  production: true,
  demoCredentials: { email: '', password: '' },
  firebase: {
    apiKey: 'YOUR_PROD_API_KEY',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    appId: 'YOUR_PROD_APP_ID',
    measurementId: 'YOUR_MEASUREMENT_ID',
  },
  useEmulators: false,
  appVersion: '1.0.0',
};
