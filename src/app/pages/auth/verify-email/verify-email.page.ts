import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButton,
  IonIcon,
  IonText,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { mailOpenOutline, refreshOutline, logOutOutline } from 'ionicons/icons';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-verify-email',
  templateUrl: './verify-email.page.html',
  styleUrls: ['./verify-email.page.scss'],
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButton,
    IonIcon,
    IonText,
  ],
})
export class VerifyEmailPage {
  private authService = inject(AuthService);
  private router = inject(Router);

  email = this.authService.currentUser?.email ?? '';
  resending = false;
  checking = false;
  status: 'idle' | 'resent' | 'still-unverified' | 'error' = 'idle';

  constructor() {
    addIcons({ mailOpenOutline, refreshOutline, logOutOutline });
  }

  async resend(): Promise<void> {
    this.resending = true;
    this.status = 'idle';
    try {
      await this.authService.resendVerificationEmail();
      this.status = 'resent';
    } catch {
      this.status = 'error';
    } finally {
      this.resending = false;
    }
  }

  async checkVerified(): Promise<void> {
    this.checking = true;
    try {
      const ok = await this.authService.refreshEmailVerificationStatus();
      if (ok) {
        await this.router.navigate(['/tabs/feed']);
      } else {
        this.status = 'still-unverified';
      }
    } finally {
      this.checking = false;
    }
  }

  async signOut(): Promise<void> {
    await this.authService.signOut();
  }
}
