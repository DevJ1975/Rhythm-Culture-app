import {
  Component,
  ElementRef,
  Input,
  OnDestroy,
  ViewChild,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonIcon } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { playOutline, pauseOutline } from 'ionicons/icons';

/**
 * Audio player with a waveform-style progress scrubber.
 * Self-contained — accepts a URL and an optional pre-computed waveform.
 */
@Component({
  selector: 'app-audio-player',
  templateUrl: './audio-player.component.html',
  styleUrls: ['./audio-player.component.scss'],
  standalone: true,
  imports: [CommonModule, IonIcon],
})
export class AudioPlayerComponent implements OnDestroy {
  @Input({ required: true }) src!: string;
  @Input() waveform: number[] = Array.from({ length: 48 }, (_, i) =>
    8 + Math.round(Math.abs(Math.sin(i * 0.7)) * 24)
  );
  @ViewChild('audio', { static: true }) audioRef!: ElementRef<HTMLAudioElement>;

  playing = false;
  progress = 0;
  duration = 0;
  current = 0;

  constructor() {
    addIcons({ playOutline, pauseOutline });
  }

  toggle(): void {
    const audio = this.audioRef.nativeElement;
    if (audio.paused) {
      audio.play().then(() => (this.playing = true)).catch(() => {});
    } else {
      audio.pause();
      this.playing = false;
    }
  }

  onLoaded(): void {
    this.duration = this.audioRef.nativeElement.duration || 0;
  }

  onTimeUpdate(): void {
    const audio = this.audioRef.nativeElement;
    this.current = audio.currentTime;
    this.progress = this.duration > 0 ? audio.currentTime / this.duration : 0;
  }

  onEnded(): void {
    this.playing = false;
    this.progress = 0;
  }

  seekTo(idx: number): void {
    if (!this.duration) return;
    const ratio = idx / Math.max(1, this.waveform.length - 1);
    this.audioRef.nativeElement.currentTime = ratio * this.duration;
  }

  fmt(seconds: number): string {
    if (!isFinite(seconds)) return '0:00';
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${m}:${s.toString().padStart(2, '0')}`;
  }

  ngOnDestroy(): void {
    if (this.audioRef?.nativeElement) {
      this.audioRef.nativeElement.pause();
    }
  }
}
