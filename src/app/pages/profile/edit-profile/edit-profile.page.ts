import { Component, OnInit, inject, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder } from '@angular/forms';
import { Router } from '@angular/router';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonButtons, IonInput, IonTextarea, IonItem, IonLabel, IonSpinner,
  IonChip, ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { chevronBackOutline, cameraOutline, checkmarkOutline } from 'ionicons/icons';
import { Capacitor } from '@capacitor/core';
import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';
import { AuthService } from '../../../core/services/auth.service';
import { UserService } from '../../../core/services/user.service';
import { StorageService } from '../../../core/services/storage.service';
import { UserProfile, ArtistSpecialty } from '../../../models';

const ALL_SPECIALTIES: ArtistSpecialty[] = [
  'Dance', 'Music', 'Vocals', 'Choreography', 'DJ',
  'Production', 'Acting', 'Rap', 'Beatboxing', 'Other',
];

@Component({
  selector: 'app-edit-profile',
  templateUrl: './edit-profile.page.html',
  styleUrls: ['./edit-profile.page.scss'],
  standalone: true,
  imports: [
    CommonModule, ReactiveFormsModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonButtons, IonInput, IonTextarea, IonItem, IonLabel, IonSpinner, IonChip,
  ],
})
export class EditProfilePage implements OnInit {
  private authService = inject(AuthService);
  private userService = inject(UserService);
  private storageService = inject(StorageService);
  private router = inject(Router);
  private fb = inject(FormBuilder);
  private toastCtrl = inject(ToastController);

  @ViewChild('photoInput') photoInput!: ElementRef<HTMLInputElement>;

  profile: UserProfile | null = null;
  isLoading = false;
  isSaving = false;
  uploadProgress = 0;
  specialties = ALL_SPECIALTIES;
  selectedSpecialties: ArtistSpecialty[] = [];

  form = this.fb.group({
    artistName: [''],
    displayName: [''],
    bio: [''],
    location: [''],
    instagramUrl: [''],
    youtubeUrl: [''],
    tiktokUrl: [''],
    websiteUrl: [''],
  });

  constructor() {
    addIcons({ chevronBackOutline, cameraOutline, checkmarkOutline });
  }

  goBack(): void { window.history.back(); }

  async ngOnInit(): Promise<void> {
    const uid = this.authService.currentUser?.uid;
    if (!uid) return;
    this.isLoading = true;
    this.profile = await this.userService.getUserProfileOnce(uid);
    if (this.profile) {
      this.selectedSpecialties = [...(this.profile.specialties ?? [])];
      this.form.patchValue({
        artistName: this.profile.artistName ?? '',
        displayName: this.profile.displayName ?? '',
        bio: this.profile.bio ?? '',
        location: this.profile.location ?? '',
        instagramUrl: this.profile.socialLinks?.instagram ?? '',
        youtubeUrl: this.profile.socialLinks?.youtube ?? '',
        tiktokUrl: this.profile.socialLinks?.tiktok ?? '',
        websiteUrl: this.profile.socialLinks?.website ?? '',
      });
    }
    this.isLoading = false;
  }

  toggleSpecialty(specialty: ArtistSpecialty): void {
    const idx = this.selectedSpecialties.indexOf(specialty);
    if (idx > -1) this.selectedSpecialties.splice(idx, 1);
    else this.selectedSpecialties.push(specialty);
  }

  isSelected(s: ArtistSpecialty): boolean {
    return this.selectedSpecialties.includes(s);
  }

  async changePhoto(): Promise<void> {
    if (Capacitor.isNativePlatform()) {
      const photo = await Camera.getPhoto({
        resultType: CameraResultType.DataUrl,
        source: CameraSource.Prompt,
        quality: 80,
        width: 500,
        height: 500,
      });
      if (!photo.dataUrl || !this.profile) return;
      const blob = await this.storageService.dataUrlToBlob(photo.dataUrl);
      this.uploadPhoto(blob);
    } else {
      this.photoInput.nativeElement.click();
    }
  }

  async onPhotoSelected(event: Event): Promise<void> {
    const input = event.target as HTMLInputElement;
    if (!input.files?.length || !this.profile) return;
    const resized = await this.storageService.resizeImage(input.files[0], 500, 500, 0.8);
    this.uploadPhoto(resized);
    input.value = '';
  }

  private uploadPhoto(blob: Blob): void {
    const uid = this.authService.currentUser!.uid;
    this.storageService.uploadProfilePhoto(uid, blob).subscribe(async (prog) => {
      this.uploadProgress = prog.progress;
      if (prog.state === 'success' && prog.downloadURL) {
        await this.userService.updateProfile(uid, { photoURL: prog.downloadURL });
        if (this.profile) this.profile.photoURL = prog.downloadURL;
      }
    });
  }

  async onSave(): Promise<void> {
    const uid = this.authService.currentUser?.uid;
    if (!uid) return;
    this.isSaving = true;
    try {
      const v = this.form.value;
      await this.userService.updateProfile(uid, {
        artistName: v.artistName ?? '',
        displayName: v.displayName ?? '',
        bio: v.bio ?? '',
        location: v.location ?? '',
        specialties: this.selectedSpecialties,
        socialLinks: {
          instagram: v.instagramUrl ?? '',
          youtube: v.youtubeUrl ?? '',
          tiktok: v.tiktokUrl ?? '',
          website: v.websiteUrl ?? '',
        },
      });
      const toast = await this.toastCtrl.create({ message: 'Profile updated!', duration: 2000, color: 'success', position: 'top' });
      await toast.present();
      await this.router.navigate(['/tabs/profile']);
    } catch {
      const toast = await this.toastCtrl.create({ message: 'Failed to save. Try again.', duration: 3000, color: 'danger', position: 'top' });
      await toast.present();
    } finally {
      this.isSaving = false;
    }
  }
}
