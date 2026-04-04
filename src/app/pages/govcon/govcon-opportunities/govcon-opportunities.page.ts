import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonButtons, IonBackButton, IonSkeletonText, IonSearchbar, IonBadge,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  chevronBackOutline, filterOutline, locationOutline,
  timeOutline, cashOutline, closeCircleOutline,
} from 'ionicons/icons';
import { GovConService } from '../../../core/services/govcon.service';
import { GovConOpportunity, SetAside, PERFORMING_ARTS_NAICS } from '../../../models';

@Component({
  selector: 'app-govcon-opportunities',
  standalone: true,
  imports: [
    CommonModule, FormsModule, RouterModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonButtons, IonBackButton, IonSkeletonText, IonSearchbar, IonBadge,
  ],
  templateUrl: './govcon-opportunities.page.html',
  styleUrls: ['./govcon-opportunities.page.scss'],
})
export class GovConOpportunitiesPage implements OnInit {
  private govconService = inject(GovConService);

  isLoading = true;
  opportunities: GovConOpportunity[] = [];
  searchKeyword = '';

  naicsCodes = PERFORMING_ARTS_NAICS;
  setAsideOptions: SetAside[] = ['Small Business', '8(a)', 'HUBZone', 'SDVOSB', 'WOSB'];

  selectedNaics: string | null = null;
  selectedSetAside: SetAside | null = null;

  constructor() {
    addIcons({
      chevronBackOutline, filterOutline, locationOutline,
      timeOutline, cashOutline, closeCircleOutline,
    });
  }

  async ngOnInit(): Promise<void> {
    await this.loadOpportunities();
  }

  async loadOpportunities(): Promise<void> {
    this.isLoading = true;
    const result = await this.govconService.getOpportunities({
      keyword: this.searchKeyword || undefined,
      naicsCode: this.selectedNaics || undefined,
      setAside: this.selectedSetAside || undefined,
    });
    this.opportunities = result.opportunities;
    this.isLoading = false;
  }

  async onSearch(event: any): Promise<void> {
    this.searchKeyword = event.detail.value || '';
    await this.loadOpportunities();
  }

  async selectNaics(code: string): Promise<void> {
    this.selectedNaics = this.selectedNaics === code ? null : code;
    await this.loadOpportunities();
  }

  async selectSetAside(sa: SetAside): Promise<void> {
    this.selectedSetAside = this.selectedSetAside === sa ? null : sa;
    await this.loadOpportunities();
  }

  async clearFilters(): Promise<void> {
    this.selectedNaics = null;
    this.selectedSetAside = null;
    this.searchKeyword = '';
    await this.loadOpportunities();
  }

  hasFilters(): boolean {
    return !!(this.selectedNaics || this.selectedSetAside || this.searchKeyword);
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

  getSetAsideColor(setAside: SetAside): string {
    const colors: Record<string, string> = {
      'Small Business': 'bg-blue-500/20 text-blue-400',
      '8(a)': 'bg-orange-500/20 text-orange-400',
      'HUBZone': 'bg-teal-500/20 text-teal-400',
      'SDVOSB': 'bg-red-500/20 text-red-400',
      'WOSB': 'bg-pink-500/20 text-pink-400',
      'None': 'bg-gray-500/20 text-gray-400',
    };
    return colors[setAside] || 'bg-gray-500/20 text-gray-400';
  }

  getNaicsDescription(code: string): string {
    return this.naicsCodes.find(n => n.code === code)?.description || code;
  }
}
