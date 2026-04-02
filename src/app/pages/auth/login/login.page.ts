import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { RouterModule } from '@angular/router';
import {
  IonContent, IonButton, IonIcon,
  IonInput, IonLabel, IonNote, IonSpinner,
  ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { logoGoogle, logoApple, eyeOutline, eyeOffOutline, mailOutline, lockClosedOutline, flashOutline } from 'ionicons/icons';
import { AuthService } from '../../../core/services/auth.service';
import { Router } from '@angular/router';
import { environment } from '../../../../environments/environment';

@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss'],
  standalone: true,
  imports: [
    CommonModule, ReactiveFormsModule, RouterModule,
    IonContent, IonButton, IonIcon, IonInput,
    IonLabel, IonNote, IonSpinner,
  ],
})
export class LoginPage {
  private authService = inject(AuthService);
  private router = inject(Router);
  private fb = inject(FormBuilder);
  private toastCtrl = inject(ToastController);

  showPassword = false;
  isLoading = false;

  loginForm = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]],
  });

  readonly isDev = !environment.production;

  constructor() {
    addIcons({ logoGoogle, logoApple, eyeOutline, eyeOffOutline, mailOutline, lockClosedOutline, flashOutline });
  }

  async onDemoLogin(): Promise<void> {
    const { email, password } = environment.demoCredentials;
    this.loginForm.setValue({ email, password });
    await this.onEmailLogin();
  }

  async onEmailLogin(): Promise<void> {
    if (this.loginForm.invalid) return;
    const { email, password } = this.loginForm.value;
    this.isLoading = true;
    try {
      await this.authService.loginWithEmail(email!, password!);
      await this.router.navigate(['/tabs/feed'], { replaceUrl: true });
    } catch (error: any) {
      await this.showError(this.getErrorMessage(error.code));
    } finally {
      this.isLoading = false;
    }
  }

  async onGoogleLogin(): Promise<void> {
    this.isLoading = true;
    try {
      await this.authService.loginWithGoogle();
      await this.router.navigate(['/tabs/feed'], { replaceUrl: true });
    } catch (error: any) {
      await this.showError(this.getErrorMessage(error.code));
    } finally {
      this.isLoading = false;
    }
  }

  async onAppleLogin(): Promise<void> {
    this.isLoading = true;
    try {
      await this.authService.loginWithApple();
      await this.router.navigate(['/tabs/feed'], { replaceUrl: true });
    } catch (error: any) {
      await this.showError(this.getErrorMessage(error.code));
    } finally {
      this.isLoading = false;
    }
  }

  private getErrorMessage(code: string): string {
    const messages: Record<string, string> = {
      'auth/invalid-credential': 'Invalid email or password. Please try again.',
      'auth/user-not-found': 'No account found with this email.',
      'auth/wrong-password': 'Incorrect password.',
      'auth/too-many-requests': 'Too many attempts. Please try again later.',
      'auth/network-request-failed': 'Network error. Check your connection.',
    };
    return messages[code] ?? 'Something went wrong. Please try again.';
  }

  private async showError(message: string): Promise<void> {
    const toast = await this.toastCtrl.create({
      message,
      duration: 3000,
      color: 'danger',
      position: 'top',
    });
    await toast.present();
  }
}
