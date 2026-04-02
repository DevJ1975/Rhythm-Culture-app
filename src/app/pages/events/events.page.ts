import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonChip, IonLabel, IonSkeletonText,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { calendarOutline, locationOutline, addOutline, globeOutline } from 'ionicons/icons';
import { Event, EventCategory } from '../../models';
import { EventService } from '../../core/services/event.service';
import { MockDataService } from '../../core/services/mock-data.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-events',
  templateUrl: './events.page.html',
  styleUrls: ['./events.page.scss'],
  standalone: true,
  imports: [
    CommonModule, RouterModule, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonChip, IonLabel, IonSkeletonText,
  ],
})
export class EventsPage implements OnInit {
  private eventService = inject(EventService);
  private mockData = inject(MockDataService);

  events: Event[] = [];
  isLoading = true;
  selectedCategory: EventCategory | null = null;

  categories: EventCategory[] = [
    'Workshop', 'Masterclass', 'Battle', 'Concert',
    'Showcase', 'Camp', 'Virtual Class', 'Audition',
  ];

  constructor() {
    addIcons({ calendarOutline, locationOutline, addOutline, globeOutline });
  }

  ngOnInit(): void {
    this.loadEvents();
  }

  async loadEvents(): Promise<void> {
    this.isLoading = true;
    try {
      if (!environment.production) {
        this.events = this.mockData.getEvents(this.selectedCategory ?? undefined);
        return;
      }
      const filters = this.selectedCategory ? { category: this.selectedCategory } : {};
      const result = await this.eventService.getUpcomingEvents(filters);
      this.events = result.events;
    } finally {
      this.isLoading = false;
    }
  }

  async filterByCategory(cat: EventCategory): Promise<void> {
    this.selectedCategory = this.selectedCategory === cat ? null : cat;
    await this.loadEvents();
  }

  formatDate(timestamp: any): string {
    const date = timestamp?.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  }

  formatTime(timestamp: any): string {
    const date = timestamp?.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
  }
}
