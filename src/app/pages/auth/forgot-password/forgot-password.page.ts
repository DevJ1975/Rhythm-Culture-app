import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { RouterModule } from '@angular/router';
import {
  IonContent, IonButton, IonIcon, IonInput, IonNote, IonSpinner,
  ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { chevronBackOutline, mailOutline, checkmarkCircleOutline } from 'ionicons/icons';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-forgot-password',
  templateUrl: './forgot-password.page.html',
  standalone: true,
  imports: [
    CommonModule, ReactiveFormsModule, RouterModule,
    IonContent, IonButton, IonIcon, IonInput, IonNote, IonSpinner,
  ],
})
export class ForgotPasswordPage {
  private authService = inject(AuthService);
  private fb = inject(FormBuilder);
  private toastCtrl = inject(ToastController);

  isLoading = false;
  emailSent = false;

  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
  });

  constructor() {
    addIcons({ chevronBackOutline, mailOutline, checkmarkCircleOutline });
  }

  async onSubmit(): Promise<void> {
    if (this.form.invalid) return;
    this.isLoading = true;
    try {
      await this.authService.sendPasswordReset(this.form.value.email!);
      this.emailSent = true;
    } catch {
      const toast = await this.toastCtrl.create({
        message: 'Could not send reset email. Check the address and try again.',
        duration: 3000,
        color: 'danger',
        position: 'top',
      });
      await toast.present();
    } finally {
      this.isLoading = false;
    }
  }
}
