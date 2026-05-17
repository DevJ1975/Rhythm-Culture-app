import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule, Router } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButton,
  IonIcon,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { checkmarkCircleOutline, closeCircleOutline } from 'ionicons/icons';

@Component({
  selector: 'app-payment-result',
  templateUrl: './payment-result.page.html',
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
  ],
})
export class PaymentResultPage implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  outcome: 'success' | 'cancel' = 'success';
  sessionId = '';

  constructor() {
    addIcons({ checkmarkCircleOutline, closeCircleOutline });
  }

  ngOnInit(): void {
    this.outcome = this.route.snapshot.data['outcome'] || 'success';
    this.sessionId = this.route.snapshot.queryParamMap.get('session_id') || '';
  }

  goHome(): void {
    this.router.navigate(['/tabs/feed']);
  }
}
