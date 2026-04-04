import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonButtons, IonBackButton, IonSkeletonText, IonInput, IonTextarea,
  IonSelect, IonSelectOption, IonCheckbox, IonItem, IonLabel,
  ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  chevronBackOutline, saveOutline, addCircleOutline, trashOutline,
  checkmarkCircleOutline, alertCircleOutline, shieldCheckmarkOutline,
} from 'ionicons/icons';
import { GovConService } from '../../../core/services/govcon.service';
import {
  GovConProfile, PastPerformance, SetAside, SamRegistrationStatus,
  PERFORMING_ARTS_NAICS,
} from '../../../models';

@Component({
  selector: 'app-govcon-profile',
  standalone: true,
  imports: [
    CommonModule, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonButtons, IonBackButton, IonSkeletonText, IonInput, IonTextarea,
    IonSelect, IonSelectOption, IonCheckbox, IonItem, IonLabel,
  ],
  templateUrl: './govcon-profile.page.html',
  styleUrls: ['./govcon-profile.page.scss'],
})
export class GovConProfilePage implements OnInit {
  private govconService = inject(GovConService);
  private toastCtrl = inject(ToastController);

  isLoading = true;
  isSaving = false;

  profile: GovConProfile = {
    userId: 'user-demo',
    naicsCodes: [],
    samRegistrationStatus: 'not_registered',
    setAsideEligibility: [],
    pastPerformance: [],
    createdAt: {} as any,
    updatedAt: {} as any,
  };

  naicsCodes = PERFORMING_ARTS_NAICS;
  setAsideOptions: SetAside[] = ['Small Business', '8(a)', 'HUBZone', 'SDVOSB', 'WOSB'];
  samStatusOptions: { value: SamRegistrationStatus; label: string }[] = [
    { value: 'active', label: 'Active' },
    { value: 'expiring', label: 'Expiring Soon' },
    { value: 'expired', label: 'Expired' },
    { value: 'not_registered', label: 'Not Registered' },
  ];

  constructor() {
    addIcons({
      chevronBackOutline, saveOutline, addCircleOutline, trashOutline,
      checkmarkCircleOutline, alertCircleOutline, shieldCheckmarkOutline,
    });
  }

  ngOnInit(): void {
    this.govconService.getGovConProfile('user-demo').subscribe((p) => {
      if (p) {
        this.profile = p;
      }
      this.isLoading = false;
    });
  }

  isNaicsSelected(code: string): boolean {
    return this.profile.naicsCodes.includes(code);
  }

  toggleNaics(code: string): void {
    const idx = this.profile.naicsCodes.indexOf(code);
    if (idx >= 0) {
      this.profile.naicsCodes.splice(idx, 1);
    } else {
      this.profile.naicsCodes.push(code);
    }
  }

  isSetAsideSelected(sa: SetAside): boolean {
    return this.profile.setAsideEligibility.includes(sa);
  }

  toggleSetAside(sa: SetAside): void {
    const idx = this.profile.setAsideEligibility.indexOf(sa);
    if (idx >= 0) {
      this.profile.setAsideEligibility.splice(idx, 1);
    } else {
      this.profile.setAsideEligibility.push(sa);
    }
  }

  addPastPerformance(): void {
    this.profile.pastPerformance.push({
      agency: '',
      description: '',
    });
  }

  removePastPerformance(index: number): void {
    this.profile.pastPerformance.splice(index, 1);
  }

  async saveProfile(): Promise<void> {
    this.isSaving = true;
    try {
      await this.govconService.saveGovConProfile(this.profile);
      const toast = await this.toastCtrl.create({
        message: 'GovCon profile saved',
        duration: 2000,
        color: 'success',
        position: 'top',
      });
      await toast.present();
    } catch {
      const toast = await this.toastCtrl.create({
        message: 'Failed to save profile',
        duration: 2000,
        color: 'danger',
        position: 'top',
      });
      await toast.present();
    } finally {
      this.isSaving = false;
    }
  }

  getSamStatusColor(): string {
    const colors: Record<string, string> = {
      active: 'text-green-400',
      expiring: 'text-yellow-400',
      expired: 'text-red-400',
      not_registered: 'text-gray-400',
    };
    return colors[this.profile.samRegistrationStatus] || 'text-gray-400';
  }

  getSamStatusIcon(): string {
    if (this.profile.samRegistrationStatus === 'active') return 'checkmark-circle-outline';
    if (this.profile.samRegistrationStatus === 'expired') return 'alert-circle-outline';
    return 'shield-checkmark-outline';
  }
}
