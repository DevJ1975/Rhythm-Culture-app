import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonList,
  IonItem,
  IonLabel,
  IonIcon,
  IonBackButton,
  IonButtons,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { checkmarkOutline } from 'ionicons/icons';
import { I18nService, SupportedLocale } from '../../../core/services/i18n.service';

@Component({
  selector: 'app-language',
  templateUrl: './language.page.html',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonList,
    IonItem,
    IonLabel,
    IonIcon,
    IonBackButton,
    IonButtons,
  ],
})
export class LanguagePage {
  i18n = inject(I18nService);

  locales: { code: SupportedLocale; name: string }[] = [
    { code: 'en', name: 'English' },
    { code: 'es', name: 'Español' },
    { code: 'fr', name: 'Français' },
  ];

  constructor() {
    addIcons({ checkmarkOutline });
  }

  select(locale: SupportedLocale): void {
    this.i18n.setLocale(locale);
  }
}
