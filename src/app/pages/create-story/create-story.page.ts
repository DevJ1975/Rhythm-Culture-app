import { Component, inject, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButton,
  IonIcon,
  IonButtons,
  IonInput,
  IonSpinner,
  IonBackButton,
  ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  cameraOutline,
  imageOutline,
  closeOutline,
  checkmarkOutline,
} from 'ionicons/icons';
import { Capacitor } from '@capacitor/core';
import { AuthService } from '../../core/services/auth.service';
import { StorageService, UploadProgress } from '../../core/services/storage.service';
import { StoryService } from '../../core/services/story.service';
import { CameraService } from '../../core/services/camera.service';

@Component({
  selector: 'app-create-story',
  templateUrl: './create-story.page.html',
  styleUrls: ['./create-story.page.scss'],
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButton,
    IonIcon,
    IonButtons,
    IonInput,
    IonSpinner,
    IonBackButton,
  ],
})
export class CreateStoryPage {
  private auth = inject(AuthService);
  private storage = inject(StorageService);
  private storyService = inject(StoryService);
  private camera = inject(CameraService);
  private router = inject(Router);
  private toastCtrl = inject(ToastController);

  @ViewChild('fileInput') fileInput!: ElementRef<HTMLInputElement>;

  preview: string | null = null;
  selectedFile: File | Blob | null = null;
  selectedType: 'image' | 'video' = 'image';
  caption = '';
  isPosting = false;
  uploadProgress = 0;

  constructor() {
    addIcons({ cameraOutline, imageOutline, closeOutline, checkmarkOutline });
  }

  async openCamera(): Promise<void> {
    if (Capacitor.isNativePlatform()) {
      const picked = await this.camera.pickImage('camera');
      if (picked) {
        this.preview = picked.dataUrl ?? URL.createObjectURL(picked.blob);
        this.selectedFile = picked.blob;
        this.selectedType = 'image';
      }
    } else {
      this.fileInput.nativeElement.click();
    }
  }

  async openGallery(): Promise<void> {
    if (Capacitor.isNativePlatform()) {
      const picked = await this.camera.pickImage('photos');
      if (picked) {
        this.preview = picked.dataUrl ?? URL.createObjectURL(picked.blob);
        this.selectedFile = picked.blob;
        this.selectedType = 'image';
      }
    } else {
      this.fileInput.nativeElement.click();
    }
  }

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    this.selectedFile = file;
    this.selectedType = file.type.startsWith('video/') ? 'video' : 'image';
    this.preview = URL.createObjectURL(file);
    input.value = '';
  }

  removeMedia(): void {
    if (this.preview && this.preview.startsWith('blob:')) {
      URL.revokeObjectURL(this.preview);
    }
    this.preview = null;
    this.selectedFile = null;
  }

  async publish(): Promise<void> {
    const uid = this.auth.currentUser?.uid;
    if (!uid || !this.selectedFile || this.isPosting) return;

    this.isPosting = true;
    try {
      const storyId = `${uid}_${Date.now()}`;
      const ext = this.selectedType === 'video' ? 'mp4' : 'jpg';
      const path = `stories/${uid}/${storyId}/${Date.now()}.${ext}`;

      const result = await new Promise<UploadProgress>((resolve, reject) => {
        this.storage.uploadFile(path, this.selectedFile!).subscribe({
          next: (p) => {
            this.uploadProgress = p.progress;
            if (p.state === 'success') resolve(p);
          },
          error: reject,
        });
      });

      if (!result.downloadURL) throw new Error('Upload failed');

      await this.storyService.create(uid, {
        mediaUrl: result.downloadURL,
        mediaType: this.selectedType,
        storagePath: path,
        caption: this.caption || undefined,
      });

      await this.router.navigate(['/tabs/feed'], { replaceUrl: true });
    } catch {
      const toast = await this.toastCtrl.create({
        message: 'Failed to post story. Try again.',
        duration: 3000,
        color: 'danger',
        position: 'top',
      });
      await toast.present();
    } finally {
      this.isPosting = false;
    }
  }
}
