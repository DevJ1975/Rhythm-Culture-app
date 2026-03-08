import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonIcon } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  searchOutline, filmOutline, peopleOutline,
  calendarOutline, schoolOutline, chatbubblesOutline, notificationsOutline,
} from 'ionicons/icons';

@Component({
  selector: 'app-empty-state',
  template: `
    <div class="flex flex-col items-center justify-center py-16 px-8 text-center">
      <div class="w-20 h-20 rounded-full bg-dark-200 flex items-center justify-center mb-6">
        <ion-icon [name]="icon" class="text-gray-600 text-4xl"></ion-icon>
      </div>
      <h3 class="text-white font-bold text-xl mb-2">{{ title }}</h3>
      <p class="text-gray-500 text-sm leading-relaxed max-w-xs">{{ message }}</p>
    </div>
  `,
  standalone: true,
  imports: [CommonModule, IonIcon],
})
export class EmptyStateComponent {
  @Input() icon = 'search-outline';
  @Input() title = 'Nothing here yet';
  @Input() message = 'Check back later for new content.';

  constructor() {
    addIcons({
      searchOutline, filmOutline, peopleOutline,
      calendarOutline, schoolOutline, chatbubblesOutline, notificationsOutline,
    });
  }
}
