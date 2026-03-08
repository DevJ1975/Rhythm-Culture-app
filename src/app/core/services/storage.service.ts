import { Injectable, inject } from '@angular/core';
import {
  Storage,
  ref,
  uploadBytesResumable,
  getDownloadURL,
  deleteObject,
  UploadTask,
} from '@angular/fire/storage';
import { Observable, from } from 'rxjs';

export interface UploadProgress {
  progress: number;
  downloadURL?: string;
  error?: Error;
  state: 'running' | 'paused' | 'success' | 'error';
}

@Injectable({
  providedIn: 'root',
})
export class StorageService {
  private storage = inject(Storage);

  // ─── Upload with Progress ─────────────────────────────────────────────────────

  uploadFile(
    storagePath: string,
    file: Blob | File,
    contentType?: string
  ): Observable<UploadProgress> {
    return new Observable<UploadProgress>((observer) => {
      const storageRef = ref(this.storage, storagePath);
      const metadata = contentType ? { contentType } : undefined;
      const uploadTask: UploadTask = uploadBytesResumable(
        storageRef,
        file,
        metadata
      );

      uploadTask.on(
        'state_changed',
        (snapshot) => {
          const progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          observer.next({
            progress,
            state: snapshot.state as UploadProgress['state'],
          });
        },
        (error) => {
          observer.next({ progress: 0, error, state: 'error' });
          observer.error(error);
        },
        async () => {
          const downloadURL = await getDownloadURL(uploadTask.snapshot.ref);
          observer.next({ progress: 100, downloadURL, state: 'success' });
          observer.complete();
        }
      );

      return () => uploadTask.cancel();
    });
  }

  // ─── Upload Profile Photo ─────────────────────────────────────────────────────

  uploadProfilePhoto(
    userId: string,
    file: Blob | File
  ): Observable<UploadProgress> {
    const fileName = `profile_${Date.now()}.jpg`;
    const path = `users/${userId}/profile/${fileName}`;
    return this.uploadFile(path, file, 'image/jpeg');
  }

  // ─── Upload Post Media ────────────────────────────────────────────────────────

  uploadPostMedia(
    userId: string,
    postId: string,
    file: Blob | File,
    mediaType: 'image' | 'video' | 'audio'
  ): Observable<UploadProgress> {
    const ext = mediaType === 'video' ? 'mp4' : mediaType === 'audio' ? 'mp3' : 'jpg';
    const contentType =
      mediaType === 'video'
        ? 'video/mp4'
        : mediaType === 'audio'
        ? 'audio/mpeg'
        : 'image/jpeg';
    const fileName = `${mediaType}_${Date.now()}.${ext}`;
    const path = `posts/${userId}/${postId}/${fileName}`;
    return this.uploadFile(path, file, contentType);
  }

  // ─── Upload Course Lesson Video ────────────────────────────────────────────────

  uploadCourseVideo(
    instructorId: string,
    courseId: string,
    file: Blob | File
  ): Observable<UploadProgress> {
    const fileName = `lesson_${Date.now()}.mp4`;
    const path = `courses/${instructorId}/${courseId}/${fileName}`;
    return this.uploadFile(path, file, 'video/mp4');
  }

  // ─── Delete File ──────────────────────────────────────────────────────────────

  async deleteFile(storagePath: string): Promise<void> {
    const storageRef = ref(this.storage, storagePath);
    await deleteObject(storageRef);
  }

  // ─── Get Download URL ─────────────────────────────────────────────────────────

  async getDownloadUrl(storagePath: string): Promise<string> {
    const storageRef = ref(this.storage, storagePath);
    return getDownloadURL(storageRef);
  }

  // ─── Convert camera photo to Blob ─────────────────────────────────────────────

  async dataUrlToBlob(dataUrl: string): Promise<Blob> {
    const response = await fetch(dataUrl);
    return response.blob();
  }

  // ─── Resize image before upload (browser) ─────────────────────────────────────

  resizeImage(
    file: File,
    maxWidth: number,
    maxHeight: number,
    quality = 0.8
  ): Promise<Blob> {
    return new Promise((resolve, reject) => {
      const img = new Image();
      const url = URL.createObjectURL(file);
      img.onload = () => {
        URL.revokeObjectURL(url);
        const canvas = document.createElement('canvas');
        let { width, height } = img;
        if (width > maxWidth) {
          height = (height * maxWidth) / width;
          width = maxWidth;
        }
        if (height > maxHeight) {
          width = (width * maxHeight) / height;
          height = maxHeight;
        }
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        if (!ctx) return reject(new Error('Canvas context error'));
        ctx.drawImage(img, 0, 0, width, height);
        canvas.toBlob(
          (blob) => {
            if (blob) resolve(blob);
            else reject(new Error('Canvas to Blob failed'));
          },
          'image/jpeg',
          quality
        );
      };
      img.onerror = reject;
      img.src = url;
    });
  }
}
