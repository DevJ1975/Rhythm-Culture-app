import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonButtons, IonBackButton, IonSkeletonText, IonBadge,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  briefcaseOutline, searchOutline, statsChartOutline, personOutline,
  chevronForwardOutline, alertCircleOutline, timeOutline, trophyOutline,
} from 'ionicons/icons';
import { GovConService } from '../../../core/services/govcon.service';
import { GovConBid, GovConOpportunity } from '../../../models';

@Component({
  selector: 'app-govcon-dashboard',
  standalone: true,
  imports: [
    CommonModule, RouterModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonButtons, IonBackButton, IonSkeletonText, IonBadge,
  ],
  templateUrl: './govcon-dashboard.page.html',
  styleUrls: ['./govcon-dashboard.page.scss'],
})
export class GovConDashboardPage implements OnInit {
  private govconService = inject(GovConService);

  isLoading = true;
  bids: GovConBid[] = [];
  opportunities: GovConOpportunity[] = [];

  pipelineCounts = { tracking: 0, preparing: 0, submitted: 0, won: 0, lost: 0 };
  upcomingDeadlines: GovConBid[] = [];

  constructor() {
    addIcons({
      briefcaseOutline, searchOutline, statsChartOutline, personOutline,
      chevronForwardOutline, alertCircleOutline, timeOutline, trophyOutline,
    });
  }

  async ngOnInit(): Promise<void> {
    await this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;

    const [bids, oppResult] = await Promise.all([
      this.govconService.getUserBids('user-demo'),
      this.govconService.getOpportunities({}, 3),
    ]);

    this.bids = bids;
    this.opportunities = oppResult.opportunities;

    this.pipelineCounts = {
      tracking: bids.filter(b => b.status === 'tracking').length,
      preparing: bids.filter(b => b.status === 'preparing').length,
      submitted: bids.filter(b => b.status === 'submitted').length,
      won: bids.filter(b => b.status === 'won').length,
      lost: bids.filter(b => b.status === 'lost').length,
    };

    this.upcomingDeadlines = bids
      .filter(b => b.status === 'tracking' || b.status === 'preparing' || b.status === 'submitted')
      .sort((a, b) => (a.dueDate?.seconds ?? 0) - (b.dueDate?.seconds ?? 0))
      .slice(0, 5);

    this.isLoading = false;
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
