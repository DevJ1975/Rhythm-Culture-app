import { Directive, ElementRef, OnDestroy, OnInit, inject } from '@angular/core';

/**
 * Plays a <video> element when it scrolls into view and pauses it when it leaves.
 * Muted-autoplay is the only autoplay browsers permit without user interaction;
 * this directive assumes the consuming template sets `muted` on the element.
 */
@Directive({
  selector: 'video[autoplayOnVisible]',
  standalone: true,
})
export class AutoplayOnVisibleDirective implements OnInit, OnDestroy {
  private host = inject(ElementRef<HTMLVideoElement>);
  private observer?: IntersectionObserver;

  ngOnInit(): void {
    const el = this.host.nativeElement;
    if (typeof IntersectionObserver === 'undefined') return;

    this.observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting && entry.intersectionRatio > 0.5) {
            // muted autoplay
            el.muted = true;
            el.play().catch(() => {});
          } else {
            el.pause();
          }
        }
      },
      { threshold: [0, 0.5, 1] }
    );
    this.observer.observe(el);
  }

  ngOnDestroy(): void {
    this.observer?.disconnect();
  }
}
