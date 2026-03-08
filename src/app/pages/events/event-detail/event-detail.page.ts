import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute } from '@angular/router';
import {
  IonHeader, IonToolbar, IonContent, IonButton, IonIcon,
  IonButtons, IonSpinner, ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { chevronBackOutline, calendarOutline, locationOutline, personOutline, shareOutline } from 'ionicons/icons';
import { Event } from '../../../models';
import { EventService } from '../../../core/services/event.service';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-event-detail',
  templateUrl: './event-detail.page.html',
  standalone: true,
  imports: [
    CommonModule, RouterModule,
    IonHeader, IonToolbar, IonContent, IonButton, IonIcon,
    IonButtons, IonSpinner,
  ],
})
export class EventDetailPage implements OnInit {
  private eventService = inject(EventService);
  private authService = inject(AuthService);
  private route = inject(ActivatedRoute);
  private toastCtrl = inject(ToastController);

  event: Event | null = null;
  isRegistered = false;
  isRegistering = false;
  isLoading = true;

  constructor() {
    addIcons({ chevronBackOutline, calendarOutline, locationOutline, personOutline, shareOutline });
  }

  goBack(): void { window.history.back(); }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id')!;
    this.eventService.getEventById(id).subscribe((event) => {
      this.event = event ?? null;
      this.isLoading = false;
    });
  }

  async register(): Promise<void> {
    if (!this.event) return;
    const uid = this.authService.currentUser?.uid;
    if (!uid) return;
    this.isRegistering = true;
    try {
      await this.eventService.registerForEvent(this.event.id, uid);
      this.isRegistered = true;
      const toast = await this.toastCtrl.create({ message: 'Registered! See you there 🎉', duration: 3000, color: 'success', position: 'top' });
      await toast.present();
    } finally {
      this.isRegistering = false;
    }
  }

  formatDate(ts: any): string {
    const d = ts?.toDate ? ts.toDate() : new Date(ts);
    return d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });
  }

  formatTime(ts: any): string {
    const d = ts?.toDate ? ts.toDate() : new Date(ts);
    return d.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
  }
}
