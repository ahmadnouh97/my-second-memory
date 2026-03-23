import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.secondmemory.app',
  appName: 'Second Memory',
  webDir: 'www',
  server: {
    androidScheme: 'https',
  },
};

export default config;
