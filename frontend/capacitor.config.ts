import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.calctek.calculator',
  appName: 'CalcTek Calculator',
  webDir: 'dist',
  server: {
    androidScheme: 'https',
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 1500,
      backgroundColor: '#FFFFFF',
      showSpinner: false,
    },
  },
  ios: {
    scheme: 'App',
  },
};

export default config;
