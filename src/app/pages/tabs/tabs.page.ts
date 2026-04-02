import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  IonTabs, IonTabBar, IonTabButton, IonIcon, IonLabel, IonBadge,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  homeOutline, home, searchOutline, search,
  addOutline, playCircleOutline, playCircle,
  personOutline, person,
} from 'ionicons/icons';
import { AuthService } from '../../core/services/auth.service';
import { NotificationService } from '../../core/services/notification.service';
import { MockDataService } from '../../core/services/mock-data.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-tabs',
  templateUrl: 'tabs.page.html',
  styleUrls: ['tabs.page.scss'],
  standalone: true,
  imports: [CommonModule, IonTabs, IonTabBar, IonTabButton, IonIcon, IonLabel, IonBadge],
})
export class TabsPage implements OnInit {
  private authService = inject(AuthService);
  private notificationService = inject(NotificationService);
  private mockData = inject(MockDataService);

  unreadNotifications = 0;

  constructor() {
    addIcons({
      homeOutline, home, searchOutline, search,
      addOutline, playCircleOutline, playCircle,
      personOutline, person,
    });
  }

  ngOnInit(): void {
    if (!environment.production) {
      this.unreadNotifications = this.mockData.getUnreadNotificationCount();
      return;
    }
    const uid = this.authService.currentUser?.uid;
    if (uid) {
      this.notificationService.getUnreadNotifications(uid).subscribe((notifs) => {
        this.unreadNotifications = notifs.length;
      });
    }
  }
}
