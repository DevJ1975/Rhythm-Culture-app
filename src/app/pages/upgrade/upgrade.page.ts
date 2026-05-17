import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButton,
  IonIcon,
  IonBackButton,
  IonButtons,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  starOutline,
  flashOutline,
  ribbonOutline,
  cloudUploadOutline,
  analyticsOutline,
  checkmarkOutline,
} from 'ionicons/icons';
import { PaymentService } from '../../core/services/payment.service';

@Component({
  selector: 'app-upgrade',
  templateUrl: './upgrade.page.html',
  styleUrls: ['./upgrade.page.scss'],
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
    IonBackButton,
    IonButtons,
  ],
})
export class UpgradePage {
  private paymentService = inject(PaymentService);
  loading = false;

  perks = [
    { icon: 'flash-outline', text: 'Advanced search filters & analytics' },
    { icon: 'cloud-upload-outline', text: '4K video uploads up to 2GB' },
    { icon: 'ribbon-outline', text: 'Pro badge on your profile' },
    { icon: 'analytics-outline', text: 'Audience insights for your posts' },
    { icon: 'star-outline', text: 'Priority support' },
  ];

  constructor() {
    addIcons({
      starOutline,
      flashOutline,
      ribbonOutline,
      cloudUploadOutline,
      analyticsOutline,
      checkmarkOutline,
    });
  }

  async subscribe(): Promise<void> {
    this.loading = true;
    try {
      await this.paymentService.checkout('pro_subscription');
    } catch (e) {
      console.error(e);
      this.loading = false;
    }
  }
}
