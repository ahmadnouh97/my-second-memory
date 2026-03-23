import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { Capacitor } from '@capacitor/core';

// send-intent plugin type declaration
declare const SendIntent: {
  checkSendIntentReceived(): Promise<{ title?: string; url?: string; text?: string } | null>;
  finish(): Promise<void>;
};

@Injectable({ providedIn: 'root' })
export class ShareService {
  constructor(private router: Router) {}

  async checkIncomingShare(): Promise<void> {
    if (!Capacitor.isNativePlatform()) return;

    try {
      const result = await SendIntent.checkSendIntentReceived();
      if (!result) return;

      const url = result.url || result.text || '';
      if (!url || !this.isValidUrl(url)) return;

      // Navigate to add-item with the shared URL pre-filled
      await this.router.navigate(['/add-item'], {
        queryParams: { url },
        replaceUrl: true,
      });

      // Must call finish() to close the Android intent activity
      await SendIntent.finish();
    } catch (err) {
      console.warn('Share intent check failed', err);
    }
  }

  private isValidUrl(str: string): boolean {
    try {
      new URL(str);
      return true;
    } catch {
      return false;
    }
  }
}
