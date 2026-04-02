import { Component, inject, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormsModule, FormBuilder, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonButtons, IonTextarea, IonSpinner, IonChip,
  ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { closeOutline, imageOutline, videocamOutline, micOutline, checkmarkOutline } from 'ionicons/icons';
import { Capacitor } from '@capacitor/core';
import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';
import { AuthService } from '../../core/services/auth.service';
import { PostService } from '../../core/services/post.service';
import { StorageService, UploadProgress } from '../../core/services/storage.service';
import { MediaItem } from '../../models';

@Component({
  selector: 'app-create-post',
  templateUrl: './create-post.page.html',
  styleUrls: ['./create-post.page.scss'],
  standalone: true,
  imports: [
    CommonModule, ReactiveFormsModule, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonButtons, IonTextarea, IonSpinner, IonChip,
  ],
})
export class CreatePostPage {
  private authService = inject(AuthService);
  private postService = inject(PostService);
  private storageService = inject(StorageService);
  private router = inject(Router);
  private fb = inject(FormBuilder);
  private toastCtrl = inject(ToastController);

  @ViewChild('fileInput') fileInput!: ElementRef<HTMLInputElement>;

  selectedMedia: { url: string; type: 'image' | 'video'; file?: File | Blob }[] = [];
  isPosting = false;
  uploadProgress = 0;
  tagInput = '';
  tags: string[] = [];

  form = this.fb.group({
    caption: ['', Validators.maxLength(2200)],
  });

  constructor() {
    addIcons({ closeOutline, imageOutline, videocamOutline, micOutline, checkmarkOutline });
  }

  async addPhoto(): Promise<void> {
    if (Capacitor.isNativePlatform()) {
      const photo = await Camera.getPhoto({
        resultType: CameraResultType.DataUrl,
        source: CameraSource.Prompt,
        quality: 85,
      });
      if (photo.dataUrl) {
        const blob = await this.storageService.dataUrlToBlob(photo.dataUrl);
        this.selectedMedia.push({ url: photo.dataUrl, type: 'image', file: blob });
      }
    } else {
      this.fileInput.nativeElement.click();
    }
  }

  async onFileSelected(event: Event): Promise<void> {
    const input = event.target as HTMLInputElement;
    if (!input.files?.length) return;
    for (const file of Array.from(input.files)) {
      const type: 'image' | 'video' = file.type.startsWith('video/') ? 'video' : 'image';
      const url = URL.createObjectURL(file);
      this.selectedMedia.push({ url, type, file });
    }
    input.value = '';
  }

  removeMedia(idx: number): void {
    this.selectedMedia.splice(idx, 1);
  }

  addTag(): void {
    const tag = this.tagInput.trim().replace(/^#/, '').toLowerCase();
    if (tag && !this.tags.includes(tag)) {
      this.tags.push(tag);
    }
    this.tagInput = '';
  }

  removeTag(tag: string): void {
    this.tags = this.tags.filter((t) => t !== tag);
  }

  async onPost(): Promise<void> {
    const uid = this.authService.currentUser?.uid;
    if (!uid || this.isPosting) return;

    this.isPosting = true;
    try {
      const postId = `${uid}_${Date.now()}`;
      const uploadedMedia: MediaItem[] = [];

      for (const media of this.selectedMedia) {
        if (media.file) {
          const path = `posts/${uid}/${postId}/${Date.now()}.${media.type === 'image' ? 'jpg' : 'mp4'}`;
          const result = await new Promise<UploadProgress>((resolve, reject) => {
            this.storageService.uploadFile(path, media.file!).subscribe({
              next: (p) => {
                this.uploadProgress = p.progress;
                if (p.state === 'success') resolve(p);
              },
              error: reject,
            });
          });
          if (result.downloadURL) {
            uploadedMedia.push({
              url: result.downloadURL,
              type: media.type,
              storagePath: path,
            });
          }
        }
      }

      await this.postService.createPost({
        authorId: uid,
        type: uploadedMedia.length > 0 ? uploadedMedia[0].type : 'text',
        caption: this.form.value.caption ?? '',
        media: uploadedMedia,
        tags: this.tags,
        likesCount: 0,
        commentsCount: 0,
        sharesCount: 0,
        viewsCount: 0,
        isPublic: true,
        allowComments: true,
      });

      await this.router.navigate(['/tabs/feed'], { replaceUrl: true });
    } catch {
      const toast = await this.toastCtrl.create({ message: 'Failed to post. Try again.', duration: 3000, color: 'danger', position: 'top' });
      await toast.present();
    } finally {
      this.isPosting = false;
    }
  }
}
