import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonButtons, IonBackButton, IonSkeletonText, IonBadge,
  ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  chevronBackOutline, bookmarkOutline, documentTextOutline,
  timeOutline, cashOutline, locationOutline, personOutline,
  mailOutline, callOutline, rocketOutline, eyeOutline,
} from 'ionicons/icons';
import { GovConService } from '../../../core/services/govcon.service';
import { GovConOpportunity, PERFORMING_ARTS_NAICS } from '../../../models';

@Component({
  selector: 'app-govcon-opportunity-detail',
  standalone: true,
  imports: [
    CommonModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonButtons, IonBackButton, IonSkeletonText, IonBadge,
  ],
  templateUrl: './govcon-opportunity-detail.page.html',
  styleUrls: ['./govcon-opportunity-detail.page.scss'],
})
export class GovConOpportunityDetailPage implements OnInit {
  private route = inject(ActivatedRoute);
  private govconService = inject(GovConService);
  private toastCtrl = inject(ToastController);

  isLoading = true;
  opportunity: GovConOpportunity | null = null;

  constructor() {
    addIcons({
      chevronBackOutline, bookmarkOutline, documentTextOutline,
      timeOutline, cashOutline, locationOutline, personOutline,
      mailOutline, callOutline, rocketOutline, eyeOutline,
    });
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.govconService.getOpportunityById(id).subscribe((opp) => {
        this.opportunity = opp ?? null;
        this.isLoading = false;
      });
    }
  }

  async trackOpportunity(): Promise<void> {
    if (!this.opportunity) return;
    try {
      await this.govconService.createBid({
        opportunityId: this.opportunity.id,
        opportunity: {
          id: this.opportunity.id,
          title: this.opportunity.title,
          agency: this.opportunity.agency,
          responseDeadline: this.opportunity.responseDeadline,
          setAside: this.opportunity.setAside,
        },
        userId: 'user-demo',
        status: 'tracking',
        dueDate: this.opportunity.responseDeadline,
      });
      const toast = await this.toastCtrl.create({
        message: 'Opportunity added to pipeline',
        duration: 2000,
        color: 'success',
        position: 'top',
      });
      await toast.present();
    } catch (error) {
      const toast = await this.toastCtrl.create({
        message: 'Failed to track opportunity',
        duration: 2000,
        color: 'danger',
        position: 'top',
      });
      await toast.present();
    }
  }

  async startBid(): Promise<void> {
    if (!this.opportunity) return;
    try {
      await this.govconService.createBid({
        opportunityId: this.opportunity.id,
        opportunity: {
          id: this.opportunity.id,
          title: this.opportunity.title,
          agency: this.opportunity.agency,
          responseDeadline: this.opportunity.responseDeadline,
          setAside: this.opportunity.setAside,
        },
        userId: 'user-demo',
        status: 'preparing',
        dueDate: this.opportunity.responseDeadline,
      });
      const toast = await this.toastCtrl.create({
        message: 'Bid started — check your pipeline',
        duration: 2000,
        color: 'success',
        position: 'top',
      });
      await toast.present();
    } catch (error) {
      const toast = await this.toastCtrl.create({
        message: 'Failed to start bid',
        duration: 2000,
        color: 'danger',
        position: 'top',
      });
      await toast.present();
    }
  }

  getDaysUntil(timestamp: any): number {
    if (!timestamp) return 0;
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp.seconds * 1000);
    return Math.ceil((date.getTime() - Date.now()) / 86_400_000);
  }

  getDeadlineColor(timestamp: any): string {
    const days = this.getDaysUntil(timestamp);
    if (days <= 7) return 'text-red-400';
    if (days <= 14) return 'text-yellow-400';
    return 'text-green-400';
  }

  formatCurrency(value?: number): string {
    if (!value) return 'TBD';
    return '$' + value.toLocaleString();
  }

  formatDate(timestamp: any): string {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp.seconds * 1000);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  }

  getNaicsDescription(code: string): string {
    return PERFORMING_ARTS_NAICS.find(n => n.code === code)?.description || code;
  }
}
