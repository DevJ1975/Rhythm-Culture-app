import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { RouterModule, Router } from '@angular/router';
import {
  IonContent, IonButton, IonIcon, IonInput, IonItem,
  IonLabel, IonNote, IonSpinner, IonChip, IonCheckbox,
  ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  chevronBackOutline, checkmarkCircle, eyeOutline, eyeOffOutline,
  personOutline, mailOutline, lockClosedOutline,
} from 'ionicons/icons';
import { AuthService } from '../../../core/services/auth.service';
import { ArtistSpecialty } from '../../../models';

const ALL_SPECIALTIES: ArtistSpecialty[] = [
  'Dance', 'Music', 'Vocals', 'Choreography',
  'DJ', 'Production', 'Acting', 'Rap',
  'Beatboxing', 'Modeling', 'Other',
];

@Component({
  selector: 'app-register',
  templateUrl: './register.page.html',
  styleUrls: ['./register.page.scss'],
  standalone: true,
  imports: [
    CommonModule, ReactiveFormsModule, RouterModule,
    IonContent, IonButton, IonIcon, IonInput,
    IonLabel, IonNote, IonSpinner, IonChip, IonCheckbox,
  ],
})
export class RegisterPage {
  private authService = inject(AuthService);
  private router = inject(Router);
  private fb = inject(FormBuilder);
  private toastCtrl = inject(ToastController);

  step = 1;
  showPassword = false;
  isLoading = false;
  specialties = ALL_SPECIALTIES;
  selectedSpecialties: ArtistSpecialty[] = [];

  registerForm = this.fb.group({
    displayName: ['', [Validators.required, Validators.minLength(2)]],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
    agreeTerms: [false, Validators.requiredTrue],
  });

  constructor() {
    addIcons({ chevronBackOutline, checkmarkCircle, eyeOutline, eyeOffOutline, personOutline, mailOutline, lockClosedOutline });
  }

  toggleSpecialty(specialty: ArtistSpecialty): void {
    const idx = this.selectedSpecialties.indexOf(specialty);
    if (idx > -1) {
      this.selectedSpecialties.splice(idx, 1);
    } else {
      this.selectedSpecialties.push(specialty);
    }
  }

  isSelected(specialty: ArtistSpecialty): boolean {
    return this.selectedSpecialties.includes(specialty);
  }

  nextStep(): void {
    if (this.step === 1 && this.registerForm.get('displayName')?.valid && this.registerForm.get('email')?.valid) {
      this.step = 2;
    }
  }

  prevStep(): void {
    if (this.step > 1) this.step--;
  }

  async onRegister(): Promise<void> {
    if (this.registerForm.invalid) return;
    const { displayName, email, password } = this.registerForm.value;
    this.isLoading = true;
    try {
      const profile = await this.authService.registerWithEmail(
        email!,
        password!,
        displayName!
      );
      // Update specialties if selected
      if (this.selectedSpecialties.length > 0) {
        const { UserService } = await import('../../../core/services/user.service');
        // Will be handled by the user service on profile page
      }
      await this.router.navigate(['/tabs/feed'], { replaceUrl: true });
    } catch (error: any) {
      const msg =
        error.code === 'auth/email-already-in-use'
          ? 'This email is already registered.'
          : 'Registration failed. Please try again.';
      const toast = await this.toastCtrl.create({ message: msg, duration: 3000, color: 'danger', position: 'top' });
      await toast.present();
    } finally {
      this.isLoading = false;
    }
  }
}
