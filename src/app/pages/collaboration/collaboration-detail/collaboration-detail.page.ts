import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute } from '@angular/router';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import {
  IonHeader, IonToolbar, IonContent, IonButton, IonIcon,
  IonButtons, IonTextarea, IonSpinner, IonModal, IonLabel,
  ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { chevronBackOutline, shareOutline, locationOutline } from 'ionicons/icons';
import { Collaboration } from '../../../models';
import { CollaborationService } from '../../../core/services/collaboration.service';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-collaboration-detail',
  templateUrl: './collaboration-detail.page.html',
  standalone: true,
  imports: [
    CommonModule, RouterModule, ReactiveFormsModule,
    IonHeader, IonToolbar, IonContent, IonButton, IonIcon,
    IonButtons, IonTextarea, IonSpinner, IonModal, IonLabel,
  ],
})
export class CollaborationDetailPage implements OnInit {
  private collabService = inject(CollaborationService);
  private authService = inject(AuthService);
  private route = inject(ActivatedRoute);
  private fb = inject(FormBuilder);
  private toastCtrl = inject(ToastController);

  collab: Collaboration | null = null;
  isLoading = true;
  isApplying = false;
  hasApplied = false;
  showApplyModal = false;

  applyForm = this.fb.group({
    message: ['', [Validators.required, Validators.minLength(20)]],
    portfolioUrl: [''],
  });

  constructor() {
    addIcons({ chevronBackOutline, shareOutline, locationOutline });
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id')!;
    this.collabService.getCollaborationById(id).subscribe((c) => {
      this.collab = c ?? null;
      this.isLoading = false;
    });
  }

  async apply(): Promise<void> {
    if (this.applyForm.invalid || !this.collab) return;
    const uid = this.authService.currentUser?.uid;
    if (!uid) return;
    this.isApplying = true;
    try {
      await this.collabService.applyToCollaboration({
        collaborationId: this.collab.id,
        applicantId: uid,
        message: this.applyForm.value.message!,
        portfolioUrl: this.applyForm.value.portfolioUrl ?? undefined,
      });
      this.hasApplied = true;
      this.showApplyModal = false;
      const toast = await this.toastCtrl.create({ message: 'Application sent! 🎉', duration: 3000, color: 'success', position: 'top' });
      await toast.present();
    } finally {
      this.isApplying = false;
    }
  }
}
