import { Injectable, inject } from '@angular/core';
import { Capacitor } from '@capacitor/core';
import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';
import { StorageService } from './storage.service';

export interface PickedMedia {
  blob: Blob;
  dataUrl?: string;
  type: 'image' | 'video';
}

/**
 * Cross-platform media picker. On native (iOS/Android) uses Capacitor Camera;
 * on web falls back to <input type="file"> via the consuming component.
 */
@Injectable({ providedIn: 'root' })
export class CameraService {
  private storage = inject(StorageService);

  isNative(): boolean {
    return Capacitor.isNativePlatform();
  }

  /** Open native camera/gallery and return a Blob. */
  async pickImage(source: 'camera' | 'photos' = 'photos'): Promise<PickedMedia | null> {
    if (!this.isNative()) {
      throw new Error('Native only — fall back to a file input in the browser.');
    }
    const photo = await Camera.getPhoto({
      resultType: CameraResultType.DataUrl,
      source: source === 'camera' ? CameraSource.Camera : CameraSource.Photos,
      quality: 85,
      allowEditing: false,
    });
    if (!photo.dataUrl) return null;
    const blob = await this.storage.dataUrlToBlob(photo.dataUrl);
    return { blob, dataUrl: photo.dataUrl, type: 'image' };
  }
}
