import { Injectable, signal } from '@angular/core';

/**
 * Lightweight runtime i18n. Replace with @ngx-translate or Angular's built-in
 * i18n if you outgrow this.
 *
 * Usage:
 *   constructor(public i18n: I18nService) {}
 *   <p>{{ i18n.t('feed.empty') }}</p>
 */
type Dict = Record<string, string>;

const en: Dict = {
  'feed.empty': 'No posts yet. Follow some artists to see their work here.',
  'feed.title': 'Feed',
  'discover.title': 'Discover',
  'discover.search.placeholder': 'Search artists, posts, #tags...',
  'profile.followers': 'Followers',
  'profile.following': 'Following',
  'profile.posts': 'Posts',
  'post.share.copied': 'Link copied',
  'post.share.shared': 'Shared',
  'verify.title': 'Verify your email',
  'verify.cta': "I've verified",
  'verify.resend': 'Resend email',
  'upgrade.title': 'Rhythm Culture Pro',
  'upgrade.cta': 'Subscribe',
  'common.cancel': 'Cancel',
  'common.save': 'Save',
  'common.delete': 'Delete',
  'common.loading': 'Loading...',
};

const es: Dict = {
  'feed.empty': 'Aún no hay publicaciones. Sigue a artistas para ver su trabajo aquí.',
  'feed.title': 'Feed',
  'discover.title': 'Descubrir',
  'discover.search.placeholder': 'Buscar artistas, publicaciones, #tags...',
  'profile.followers': 'Seguidores',
  'profile.following': 'Siguiendo',
  'profile.posts': 'Publicaciones',
  'post.share.copied': 'Enlace copiado',
  'post.share.shared': 'Compartido',
  'verify.title': 'Verifica tu correo',
  'verify.cta': 'He verificado',
  'verify.resend': 'Reenviar correo',
  'upgrade.title': 'Rhythm Culture Pro',
  'upgrade.cta': 'Suscribirse',
  'common.cancel': 'Cancelar',
  'common.save': 'Guardar',
  'common.delete': 'Eliminar',
  'common.loading': 'Cargando...',
};

const fr: Dict = {
  'feed.empty': "Aucune publication. Suivez des artistes pour voir leurs créations ici.",
  'feed.title': 'Fil',
  'discover.title': 'Découvrir',
  'discover.search.placeholder': 'Rechercher artistes, posts, #tags...',
  'profile.followers': 'Abonnés',
  'profile.following': 'Abonnements',
  'profile.posts': 'Publications',
  'post.share.copied': 'Lien copié',
  'post.share.shared': 'Partagé',
  'verify.title': 'Vérifiez votre e-mail',
  'verify.cta': "J'ai vérifié",
  'verify.resend': "Renvoyer l'e-mail",
  'upgrade.title': 'Rhythm Culture Pro',
  'upgrade.cta': 'S’abonner',
  'common.cancel': 'Annuler',
  'common.save': 'Enregistrer',
  'common.delete': 'Supprimer',
  'common.loading': 'Chargement...',
};

const STRINGS: Record<string, Dict> = { en, es, fr };

export type SupportedLocale = keyof typeof STRINGS;

@Injectable({ providedIn: 'root' })
export class I18nService {
  /** Reactive current locale — components can re-render via Angular signals. */
  readonly locale = signal<SupportedLocale>(this.detect());

  setLocale(locale: SupportedLocale): void {
    if (STRINGS[locale]) {
      this.locale.set(locale);
      try {
        localStorage.setItem('rc.locale', locale);
      } catch {
        // Ignore storage errors (private mode, SSR)
      }
    }
  }

  t(key: string): string {
    const dict = STRINGS[this.locale()] || en;
    return dict[key] ?? en[key] ?? key;
  }

  available(): SupportedLocale[] {
    return Object.keys(STRINGS) as SupportedLocale[];
  }

  private detect(): SupportedLocale {
    try {
      const saved = localStorage.getItem('rc.locale') as SupportedLocale | null;
      if (saved && STRINGS[saved]) return saved;
    } catch {
      // Ignore
    }
    const browser = (navigator.language || 'en').slice(0, 2);
    return (STRINGS[browser] ? browser : 'en') as SupportedLocale;
  }
}
