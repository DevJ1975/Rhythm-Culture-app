import { Component, Input, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonList,
  IonItem,
  IonLabel,
  IonRadio,
  IonRadioGroup,
  IonTextarea,
  IonButton,
  IonButtons,
  IonIcon,
  ModalController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { closeOutline } from 'ionicons/icons';
import { AuthService } from '../../../core/services/auth.service';
import { ReportService } from '../../../core/services/report.service';
import { ReportReason, ReportTargetType } from '../../../models';

@Component({
  selector: 'app-report-dialog',
  templateUrl: './report-dialog.component.html',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonList,
    IonItem,
    IonLabel,
    IonRadio,
    IonRadioGroup,
    IonTextarea,
    IonButton,
    IonButtons,
    IonIcon,
  ],
})
export class ReportDialogComponent {
  @Input({ required: true }) targetType!: ReportTargetType;
  @Input({ required: true }) targetId!: string;

  private auth = inject(AuthService);
  private reports = inject(ReportService);
  private modal = inject(ModalController);

  reason: ReportReason = 'spam';
  details = '';
  submitting = false;

  reasons: { value: ReportReason; label: string }[] = [
    { value: 'spam', label: 'Spam' },
    { value: 'harassment', label: 'Harassment or bullying' },
    { value: 'hate_speech', label: 'Hate speech' },
    { value: 'nudity', label: 'Nudity or sexual content' },
    { value: 'violence', label: 'Violence or dangerous behavior' },
    { value: 'misinformation', label: 'False information' },
    { value: 'intellectual_property', label: 'Intellectual property violation' },
    { value: 'other', label: 'Something else' },
  ];

  constructor() {
    addIcons({ closeOutline });
  }

  async submit(): Promise<void> {
    const uid = this.auth.currentUser?.uid;
    if (!uid || this.submitting) return;
    this.submitting = true;
    try {
      await this.reports.submitReport(
        uid,
        { type: this.targetType, id: this.targetId },
        this.reason,
        this.details
      );
      await this.modal.dismiss({ submitted: true });
    } finally {
      this.submitting = false;
    }
  }

  close(): void {
    this.modal.dismiss();
  }
}
