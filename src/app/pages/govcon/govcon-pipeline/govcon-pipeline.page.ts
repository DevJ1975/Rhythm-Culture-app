import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonButtons, IonBackButton, IonSkeletonText, IonSegment, IonSegmentButton,
  IonLabel, ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  chevronBackOutline, timeOutline, cashOutline, swapHorizontalOutline,
  trashOutline, chevronForwardOutline,
} from 'ionicons/icons';
import { GovConService } from '../../../core/services/govcon.service';
import { GovConBid, BidStatus } from '../../../models';

@Component({
  selector: 'app-govcon-pipeline',
  standalone: true,
  imports: [
    CommonModule, FormsModule, RouterModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonButtons, IonBackButton, IonSkeletonText, IonSegment, IonSegmentButton,
    IonLabel,
  ],
  templateUrl: './govcon-pipeline.page.html',
  styleUrls: ['./govcon-pipeline.page.scss'],
})
export class GovConPipelinePage implements OnInit {
  private govconService = inject(GovConService);
  private toastCtrl = inject(ToastController);

  isLoading = true;
  allBids: GovConBid[] = [];
  filteredBids: GovConBid[] = [];
  activeSegment: BidStatus = 'tracking';

  stages: { value: BidStatus; label: string }[] = [
    { value: 'tracking', label: 'Tracking' },
    { value: 'preparing', label: 'Preparing' },
    { value: 'submitted', label: 'Submitted' },
    { value: 'won', label: 'Won' },
    { value: 'lost', label: 'Lost' },
  ];

  constructor() {
    addIcons({
      chevronBackOutline, timeOutline, cashOutline, swapHorizontalOutline,
      trashOutline, chevronForwardOutline,
    });
  }

  async ngOnInit(): Promise<void> {
    await this.loadBids();
  }

  async loadBids(): Promise<void> {
    this.isLoading = true;
    this.allBids = await this.govconService.getUserBids('user-demo');
    this.filterBids();
    this.isLoading = false;
  }

  onSegmentChange(event: any): void {
    this.activeSegment = event.detail.value as BidStatus;
    this.filterBids();
  }

  filterBids(): void {
    this.filteredBids = this.allBids.filter(b => b.status === this.activeSegment);
  }

  getStageCount(status: BidStatus): number {
    return this.allBids.filter(b => b.status === status).length;
  }

  async advanceBid(bid: GovConBid): Promise<void> {
    const nextStatus = this.getNextStatus(bid.status);
    if (!nextStatus) return;

    try {
      await this.govconService.updateBid(bid.id, { status: nextStatus });
      bid.status = nextStatus;
      this.filterBids();
      const toast = await this.toastCtrl.create({
        message: `Bid moved to ${nextStatus}`,
        duration: 1500,
        color: 'success',
        position: 'top',
      });
      await toast.present();
    } catch {
      const toast = await this.toastCtrl.create({
        message: 'Failed to update bid',
        duration: 2000,
        color: 'danger',
        position: 'top',
      });
      await toast.present();
    }
  }

  getNextStatus(current: BidStatus): BidStatus | null {
    const flow: Record<string, BidStatus> = {
      tracking: 'preparing',
      preparing: 'submitted',
    };
    return flow[current] || null;
  }

  getNextStatusLabel(current: BidStatus): string | null {
    const labels: Record<string, string> = {
      tracking: 'Start Preparing',
      preparing: 'Mark Submitted',
    };
    return labels[current] || null;
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
    if (!value) return '—';
    return '$' + value.toLocaleString();
  }

  getStatusColor(status: string): string {
    const colors: Record<string, string> = {
      tracking: 'bg-blue-500/20 text-blue-400',
      preparing: 'bg-yellow-500/20 text-yellow-400',
      submitted: 'bg-purple-500/20 text-purple-400',
      won: 'bg-green-500/20 text-green-400',
      lost: 'bg-red-500/20 text-red-400',
    };
    return colors[status] || 'bg-gray-500/20 text-gray-400';
  }
}
