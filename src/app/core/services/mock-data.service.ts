import { Injectable } from '@angular/core';
import { UserProfile, Post, Collaboration, ArtistSpecialty, Event, Course, Notification } from '../../models';

// Timestamps — past
const ts = (daysAgo: number, hoursAgo = 0): any => ({
  toDate: () => new Date(Date.now() - daysAgo * 86_400_000 - hoursAgo * 3_600_000),
  seconds: Math.floor((Date.now() - daysAgo * 86_400_000) / 1000),
  nanoseconds: 0,
});

// Timestamps — future
const future = (daysFromNow: number, hour = 19): any => {
  const d = new Date();
  d.setDate(d.getDate() + daysFromNow);
  d.setHours(hour, 0, 0, 0);
  return {
    toDate: () => d,
    seconds: Math.floor(d.getTime() / 1000),
    nanoseconds: 0,
  };
};

// ─── Story type (local to mock) ───────────────────────────────────────────────

export interface MockStory {
  uid: string;
  displayName: string;
  artistName?: string;
  photoURL: string;
  isVerified: boolean;
  isOwn?: boolean;
}

// ─── Profiles ────────────────────────────────────────────────────────────────

const PROFILES: Record<string, UserProfile> = {
  'user-marcus': {
    uid: 'user-marcus',
    email: 'marcus@demo.com',
    displayName: 'Marcus Johnson',
    artistName: 'MJAY',
    photoURL: 'https://i.pravatar.cc/200?u=marcus',
    coverPhotoURL: 'https://picsum.photos/seed/marcuscover/900/320',
    bio: 'Hip Hop dancer & choreographer. Creator of The Wave Movement. Turning the streets of NYC into a stage, one cipher at a time. 🔥',
    location: 'New York, USA',
    specialties: ['Dance', 'Choreography', 'Hip Hop'] as ArtistSpecialty[],
    followersCount: 24800,
    followingCount: 312,
    postsCount: 47,
    isVerified: true,
    isPro: true,
    isPublic: true,
    fcmTokens: [],
    createdAt: ts(365),
    updatedAt: ts(2),
  },
  'user-zara': {
    uid: 'user-zara',
    email: 'zara@demo.com',
    displayName: 'Zara Williams',
    artistName: 'ZaraW',
    photoURL: 'https://i.pravatar.cc/200?u=zara',
    coverPhotoURL: 'https://picsum.photos/seed/zaracover/900/320',
    bio: 'Contemporary choreographer & vocalist. Bridging movement and melody. Faculty @ Alvin Ailey. ✨ LA / NYC',
    location: 'Los Angeles, USA',
    specialties: ['Choreography', 'Vocals', 'Dance'] as ArtistSpecialty[],
    followersCount: 81200,
    followingCount: 890,
    postsCount: 132,
    isVerified: true,
    isPro: true,
    isPublic: true,
    fcmTokens: [],
    createdAt: ts(500),
    updatedAt: ts(1),
  },
  'user-karim': {
    uid: 'user-karim',
    email: 'karim@demo.com',
    displayName: 'Karim Hassan',
    artistName: 'DJ K-Flow',
    photoURL: 'https://i.pravatar.cc/200?u=karim',
    coverPhotoURL: 'https://picsum.photos/seed/karimcover/900/320',
    bio: 'DJ & Producer. Fusing Afrobeats, House & Electronic. Residency @Fabric London. Available for bookings & collabs 🎛️',
    location: 'London, UK',
    specialties: ['DJ', 'Production', 'Music'] as ArtistSpecialty[],
    followersCount: 152000,
    followingCount: 2100,
    postsCount: 289,
    isVerified: true,
    isPro: true,
    isPublic: true,
    fcmTokens: [],
    createdAt: ts(720),
    updatedAt: ts(0),
  },
  'user-sofia': {
    uid: 'user-sofia',
    email: 'sofia@demo.com',
    displayName: 'Sofia Chen',
    artistName: 'Sofia C',
    photoURL: 'https://i.pravatar.cc/200?u=sofia',
    coverPhotoURL: 'https://picsum.photos/seed/sofiacover/900/320',
    bio: 'Contemporary & Ballet dancer. Former NBS principal. Now creating work that blurs the line between concert dance and theatre 🩰',
    location: 'Toronto, Canada',
    specialties: ['Dance', 'Choreography'] as ArtistSpecialty[],
    followersCount: 37400,
    followingCount: 614,
    postsCount: 88,
    isVerified: false,
    isPro: true,
    isPublic: true,
    fcmTokens: [],
    createdAt: ts(200),
    updatedAt: ts(3),
  },
  'user-andre': {
    uid: 'user-andre',
    email: 'andre@demo.com',
    displayName: 'Andre Baptiste',
    artistName: 'Dré B',
    photoURL: 'https://i.pravatar.cc/200?u=andre',
    coverPhotoURL: 'https://picsum.photos/seed/andrecover/900/320',
    bio: 'Rapper · Beatboxer · Songwriter. Atlanta raised, world-ready. New EP "Blueprint" dropping soon 🎤',
    location: 'Atlanta, USA',
    specialties: ['Rap', 'Beatboxing', 'Vocals'] as ArtistSpecialty[],
    followersCount: 56100,
    followingCount: 428,
    postsCount: 201,
    isVerified: false,
    isPro: false,
    isPublic: true,
    fcmTokens: [],
    createdAt: ts(300),
    updatedAt: ts(1),
  },
  'user-demo': {
    uid: 'user-demo',
    email: 'demo@rhythmculture.app',
    displayName: 'Alex Rivera',
    artistName: 'ALEX R',
    photoURL: 'https://i.pravatar.cc/200?u=alexrivera',
    coverPhotoURL: 'https://picsum.photos/seed/alexcover/900/320',
    bio: 'Multi-disciplinary artist — dancer, vocalist, producer. Based in Miami. Creating from the soul. 🌊',
    location: 'Miami, USA',
    specialties: ['Dance', 'Vocals', 'Production'] as ArtistSpecialty[],
    followersCount: 4200,
    followingCount: 530,
    postsCount: 23,
    isVerified: false,
    isPro: false,
    isPublic: true,
    fcmTokens: [],
    createdAt: ts(90),
    updatedAt: ts(0),
  },
};

// ─── Posts ───────────────────────────────────────────────────────────────────

const POSTS: Post[] = [
  {
    id: 'post-1',
    authorId: 'user-marcus',
    author: { uid: 'user-marcus', displayName: 'Marcus Johnson', artistName: 'MJAY', photoURL: 'https://i.pravatar.cc/200?u=marcus', specialties: ['Dance', 'Choreography'] as ArtistSpecialty[], isVerified: true },
    type: 'video',
    caption: 'New cipher drop 🔥 Been working on this wave sequence for 3 weeks. The moment it all clicked felt unreal. Who else is obsessed with body isolation right now?',
    media: [{ url: 'https://picsum.photos/seed/dance1/600/900', thumbnailUrl: 'https://picsum.photos/seed/dance1/600/900', type: 'video', storagePath: 'mock/post-1.mp4', duration: 47, width: 600, height: 900 }],
    tags: ['hiphop', 'dance', 'cipher', 'wavestyle', 'NYC'],
    likesCount: 3841, commentsCount: 214, sharesCount: 892, viewsCount: 84200,
    isPublic: true, allowComments: true, createdAt: ts(0, 3), updatedAt: ts(0, 3),
  },
  {
    id: 'post-2',
    authorId: 'user-zara',
    author: { uid: 'user-zara', displayName: 'Zara Williams', artistName: 'ZaraW', photoURL: 'https://i.pravatar.cc/200?u=zara', specialties: ['Choreography', 'Vocals'] as ArtistSpecialty[], isVerified: true },
    type: 'image',
    caption: 'Rehearsal for the Spring showcase. The cast has been incredible — watching these artists grow over the past 6 weeks has been everything. Can\'t wait to share this work with the world 🌹',
    media: [{ url: 'https://picsum.photos/seed/rehearsal2/800/800', thumbnailUrl: 'https://picsum.photos/seed/rehearsal2/800/800', type: 'image', storagePath: 'mock/post-2.jpg', width: 800, height: 800 }],
    tags: ['contemporary', 'choreography', 'rehearsal', 'showcase'],
    likesCount: 9204, commentsCount: 431, sharesCount: 1820, viewsCount: 0,
    isPublic: true, allowComments: true, createdAt: ts(0, 7), updatedAt: ts(0, 7),
  },
  {
    id: 'post-3',
    authorId: 'user-karim',
    author: { uid: 'user-karim', displayName: 'Karim Hassan', artistName: 'DJ K-Flow', photoURL: 'https://i.pravatar.cc/200?u=karim', specialties: ['DJ', 'Production'] as ArtistSpecialty[], isVerified: true },
    type: 'audio',
    caption: 'Late night studio session — dropped this Afrohouse edit of a track I\'ve been sitting on for months. London 3am energy. 🎛️ Full release next week.',
    media: [{ url: 'mock/audio-track.mp3', type: 'audio', storagePath: 'mock/post-3.mp3', duration: 212 }],
    tags: ['afrohouse', 'dj', 'production', 'london', 'studio'],
    likesCount: 5612, commentsCount: 287, sharesCount: 2341, viewsCount: 0,
    isPublic: true, allowComments: true, createdAt: ts(1), updatedAt: ts(1),
  },
  {
    id: 'post-4',
    authorId: 'user-sofia',
    author: { uid: 'user-sofia', displayName: 'Sofia Chen', artistName: 'Sofia C', photoURL: 'https://i.pravatar.cc/200?u=sofia', specialties: ['Dance', 'Choreography'] as ArtistSpecialty[], isVerified: false },
    type: 'image',
    caption: 'Exploring the intersection of stillness and motion in today\'s rehearsal. Sometimes the most powerful moments happen between the steps. 🩰',
    media: [{ url: 'https://picsum.photos/seed/ballet4/800/1000', thumbnailUrl: 'https://picsum.photos/seed/ballet4/800/1000', type: 'image', storagePath: 'mock/post-4.jpg', width: 800, height: 1000 }],
    tags: ['contemporary', 'ballet', 'dance', 'movement', 'toronto'],
    likesCount: 4127, commentsCount: 183, sharesCount: 614, viewsCount: 0,
    isPublic: true, allowComments: true, createdAt: ts(1, 5), updatedAt: ts(1, 5),
  },
  {
    id: 'post-5',
    authorId: 'user-andre',
    author: { uid: 'user-andre', displayName: 'Andre Baptiste', artistName: 'Dré B', photoURL: 'https://i.pravatar.cc/200?u=andre', specialties: ['Rap', 'Beatboxing'] as ArtistSpecialty[], isVerified: false },
    type: 'video',
    caption: 'Dropped a freestyle over K-Flow\'s new beat. This collab was inevitable 🔥 Two cities, one frequency. @DJKFlow you cooked on this one.',
    media: [{ url: 'https://picsum.photos/seed/rap5/600/800', thumbnailUrl: 'https://picsum.photos/seed/rap5/600/800', type: 'video', storagePath: 'mock/post-5.mp4', duration: 93, width: 600, height: 800 }],
    tags: ['rap', 'freestyle', 'collab', 'atlanta', 'hiphop'],
    likesCount: 7823, commentsCount: 549, sharesCount: 3102, viewsCount: 162000,
    isPublic: true, allowComments: true, createdAt: ts(2), updatedAt: ts(2),
  },
  {
    id: 'post-6',
    authorId: 'user-marcus',
    author: { uid: 'user-marcus', displayName: 'Marcus Johnson', artistName: 'MJAY', photoURL: 'https://i.pravatar.cc/200?u=marcus', specialties: ['Dance', 'Choreography'] as ArtistSpecialty[], isVerified: true },
    type: 'text',
    caption: '🧵 Thread on why unlearning is just as important as learning in dance. After 15 years I\'m still constantly breaking down habits I built in my first year. Your body remembers everything — make sure it\'s remembering the right things. What habits have you had to unlearn?',
    media: [],
    tags: ['dancetips', 'growth', 'mindset', 'choreography'],
    likesCount: 2910, commentsCount: 398, sharesCount: 1204, viewsCount: 0,
    isPublic: true, allowComments: true, createdAt: ts(3), updatedAt: ts(3),
  },
  {
    id: 'post-7',
    authorId: 'user-zara',
    author: { uid: 'user-zara', displayName: 'Zara Williams', artistName: 'ZaraW', photoURL: 'https://i.pravatar.cc/200?u=zara', specialties: ['Choreography', 'Vocals'] as ArtistSpecialty[], isVerified: true },
    type: 'video',
    caption: 'Original vocal piece over a track I wrote last year. Finally got the courage to share this one — it\'s deeply personal. Movement is language, and so is song. 🎵',
    media: [{ url: 'https://picsum.photos/seed/vocals7/600/900', thumbnailUrl: 'https://picsum.photos/seed/vocals7/600/900', type: 'video', storagePath: 'mock/post-7.mp4', duration: 138, width: 600, height: 900 }],
    tags: ['vocals', 'original', 'songwriting', 'rnb'],
    likesCount: 11340, commentsCount: 827, sharesCount: 4590, viewsCount: 241000,
    isPublic: true, allowComments: true, createdAt: ts(4), updatedAt: ts(4),
  },
  {
    id: 'post-8',
    authorId: 'user-karim',
    author: { uid: 'user-karim', displayName: 'Karim Hassan', artistName: 'DJ K-Flow', photoURL: 'https://i.pravatar.cc/200?u=karim', specialties: ['DJ', 'Production'] as ArtistSpecialty[], isVerified: true },
    type: 'image',
    caption: 'Fabric London residency — this crowd is something else every single time. 3,000 people moving as one. This is why we do it. 🙏',
    media: [{ url: 'https://picsum.photos/seed/club8/900/600', thumbnailUrl: 'https://picsum.photos/seed/club8/900/600', type: 'image', storagePath: 'mock/post-8.jpg', width: 900, height: 600 }],
    tags: ['dj', 'london', 'fabriclondon', 'afrohouse', 'live'],
    likesCount: 18420, commentsCount: 1023, sharesCount: 7811, viewsCount: 0,
    isPublic: true, allowComments: true, createdAt: ts(5), updatedAt: ts(5),
  },
];

// ─── Collaborations ───────────────────────────────────────────────────────────

const COLLABORATIONS: Collaboration[] = [
  {
    id: 'collab-1', creatorId: 'user-zara',
    creator: { uid: 'user-zara', displayName: 'Zara Williams', artistName: 'ZaraW', photoURL: 'https://i.pravatar.cc/200?u=zara', specialties: ['Choreography', 'Vocals'] as ArtistSpecialty[], isVerified: true },
    title: 'Seeking Male Dancer for Spring Showcase', description: 'Looking for an experienced contemporary/hip-hop male dancer for a 10-min duet piece premiering at the Joyce Theater in May. Rehearsals begin April 15th in NYC.',
    type: 'Casting Call', skills: ['Dance', 'Choreography'] as ArtistSpecialty[], location: 'New York, USA',
    isRemote: false, isPaid: true, compensationDetails: '$800 + performance fee', status: 'open',
    currentApplicants: 14, maxApplicants: 1, applicationDeadline: future(15),
    tags: ['dance', 'contemporary', 'hiphop', 'casting'], createdAt: ts(7), updatedAt: ts(1),
  },
  {
    id: 'collab-2', creatorId: 'user-karim',
    creator: { uid: 'user-karim', displayName: 'Karim Hassan', artistName: 'DJ K-Flow', photoURL: 'https://i.pravatar.cc/200?u=karim', specialties: ['DJ', 'Production'] as ArtistSpecialty[], isVerified: true },
    title: 'Vocalist Needed — EP Feature', description: 'Working on an Afrobeats/R&B EP and looking for a vocalist with strong melodic instincts for 2-3 tracks. Remote collaboration is fine. Will split credits & revenue.',
    type: 'Project', skills: ['Vocals', 'Music'] as ArtistSpecialty[], location: 'London, UK',
    isRemote: true, isPaid: true, compensationDetails: 'Revenue share + flat fee per track', status: 'open',
    currentApplicants: 31, maxApplicants: 3, applicationDeadline: future(30),
    tags: ['vocals', 'afrobeats', 'rnb', 'ep', 'remote'], createdAt: ts(10), updatedAt: ts(2),
  },
  {
    id: 'collab-3', creatorId: 'user-marcus',
    creator: { uid: 'user-marcus', displayName: 'Marcus Johnson', artistName: 'MJAY', photoURL: 'https://i.pravatar.cc/200?u=marcus', specialties: ['Dance', 'Choreography'] as ArtistSpecialty[], isVerified: true },
    title: 'Looking For Videographer — NYC Cipher Series', description: 'Running a weekly cipher series in Brooklyn and need a videographer who understands street dance culture. Must be able to shoot in low-light environments. Episode drops every Friday.',
    type: 'Looking For', skills: ['Production'] as ArtistSpecialty[], location: 'New York, USA',
    isRemote: false, isPaid: true, compensationDetails: '$200/session', status: 'open',
    currentApplicants: 7, maxApplicants: 1, applicationDeadline: future(20),
    tags: ['videography', 'cipher', 'hiphop', 'brooklyn'], createdAt: ts(14), updatedAt: ts(3),
  },
  {
    id: 'collab-4', creatorId: 'user-sofia',
    creator: { uid: 'user-sofia', displayName: 'Sofia Chen', artistName: 'Sofia C', photoURL: 'https://i.pravatar.cc/200?u=sofia', specialties: ['Dance', 'Choreography'] as ArtistSpecialty[], isVerified: false },
    title: 'Composer Sought — New Evening-Length Work', description: 'Developing a 45-minute dance work exploring climate & displacement. Seeking a composer to create an original score. Based in Toronto but open to remote collaboration for composition phase.',
    type: 'Project', skills: ['Music', 'Production'] as ArtistSpecialty[], location: 'Toronto, Canada',
    isRemote: true, isPaid: true, compensationDetails: 'CAD $3,000 commissioning fee', status: 'open',
    currentApplicants: 9, maxApplicants: 1, applicationDeadline: future(45),
    tags: ['composer', 'contemporary', 'newwork', 'toronto'], createdAt: ts(20), updatedAt: ts(5),
  },
];

// ─── Events ───────────────────────────────────────────────────────────────────

const EVENTS: Event[] = [
  {
    id: 'event-1', organizerId: 'user-marcus',
    organizer: { uid: 'user-marcus', displayName: 'Marcus Johnson', artistName: 'MJAY', photoURL: 'https://i.pravatar.cc/200?u=marcus', specialties: ['Dance'] as ArtistSpecialty[], isVerified: true },
    title: 'NYC Hip Hop Battle Championship', description: 'The biggest hip hop battle competition in New York City returns. Open categories: 1v1 Breaking, Popping, Locking, and All-Styles. Judged by legendary NYC breakers. Prize pool $5,000.',
    coverImageUrl: 'https://picsum.photos/seed/battle-event/900/500',
    category: 'Battle', format: 'in-person',
    location: { venue: 'Brooklyn Steel', city: 'New York', state: 'NY', country: 'USA' },
    eventDate: future(14, 18), currentAttendees: 312, maxAttendees: 500,
    price: 25, currency: 'USD', isFree: false,
    tags: ['battle', 'hiphop', 'breaking', 'nyc'], skills: ['Dance'] as ArtistSpecialty[],
    isPublished: true, isCancelled: false, createdAt: ts(30), updatedAt: ts(2),
  },
  {
    id: 'event-2', organizerId: 'user-karim',
    organizer: { uid: 'user-karim', displayName: 'Karim Hassan', artistName: 'DJ K-Flow', photoURL: 'https://i.pravatar.cc/200?u=karim', specialties: ['DJ', 'Production'] as ArtistSpecialty[], isVerified: true },
    title: 'Afrohouse Production Masterclass', description: 'Join DJ K-Flow for a 3-hour deep dive into Afrohouse production — sound design, drum programming, mixing for the dancefloor. Includes project files and a live Q&A session.',
    coverImageUrl: 'https://picsum.photos/seed/djclass-event/900/500',
    category: 'Masterclass', format: 'virtual',
    location: { virtualLink: 'https://zoom.us/j/mock', city: 'Online', country: 'Global' },
    eventDate: future(7, 20), currentAttendees: 89, maxAttendees: 200,
    price: 45, currency: 'USD', isFree: false,
    tags: ['afrohouse', 'production', 'dj', 'masterclass', 'virtual'], skills: ['DJ', 'Production'] as ArtistSpecialty[],
    isPublished: true, isCancelled: false, createdAt: ts(14), updatedAt: ts(1),
  },
  {
    id: 'event-3', organizerId: 'user-zara',
    organizer: { uid: 'user-zara', displayName: 'Zara Williams', artistName: 'ZaraW', photoURL: 'https://i.pravatar.cc/200?u=zara', specialties: ['Choreography', 'Vocals'] as ArtistSpecialty[], isVerified: true },
    title: 'Movement & Melody Spring Showcase', description: 'An evening of original contemporary dance and live vocal performance. Featuring 12 emerging artists from across the performing arts community. Doors open at 7pm.',
    coverImageUrl: 'https://picsum.photos/seed/showcase-event/900/500',
    category: 'Showcase', format: 'in-person',
    location: { venue: 'The Joyce Theater', city: 'New York', state: 'NY', country: 'USA' },
    eventDate: future(21, 19), currentAttendees: 187, maxAttendees: 250,
    price: 0, currency: 'USD', isFree: true,
    tags: ['showcase', 'contemporary', 'vocals', 'live'], skills: ['Dance', 'Vocals', 'Choreography'] as ArtistSpecialty[],
    isPublished: true, isCancelled: false, createdAt: ts(20), updatedAt: ts(3),
  },
  {
    id: 'event-4', organizerId: 'user-sofia',
    organizer: { uid: 'user-sofia', displayName: 'Sofia Chen', artistName: 'Sofia C', photoURL: 'https://i.pravatar.cc/200?u=sofia', specialties: ['Dance', 'Choreography'] as ArtistSpecialty[], isVerified: false },
    title: 'Breaking for Beginners — Weekend Intensive', description: 'New to breaking? This two-day intensive covers foundational footwork, freezes, and toprock. All experience levels welcome. Limited to 20 participants for hands-on coaching.',
    coverImageUrl: 'https://picsum.photos/seed/workshop-event/900/500',
    category: 'Workshop', format: 'in-person',
    location: { venue: 'Harbourfront Centre', city: 'Toronto', state: 'ON', country: 'Canada' },
    eventDate: future(10, 10), currentAttendees: 16, maxAttendees: 20,
    price: 35, currency: 'CAD', isFree: false,
    tags: ['breaking', 'beginners', 'workshop', 'toronto'], skills: ['Dance'] as ArtistSpecialty[],
    isPublished: true, isCancelled: false, createdAt: ts(12), updatedAt: ts(1),
  },
  {
    id: 'event-5', organizerId: 'user-andre',
    organizer: { uid: 'user-andre', displayName: 'Andre Baptiste', artistName: 'Dré B', photoURL: 'https://i.pravatar.cc/200?u=andre', specialties: ['Rap', 'Vocals'] as ArtistSpecialty[], isVerified: false },
    title: 'Open Mic Night — All Artists Welcome', description: 'Monthly open mic celebrating all performing art forms — rap, spoken word, singing, dance, beatbox. Sign up at the door. 3-minute slots. Hosted by Dré B. Free entry all night.',
    coverImageUrl: 'https://picsum.photos/seed/openmic-event/900/500',
    category: 'Open Mic', format: 'in-person',
    location: { venue: 'The Masquerade', city: 'Atlanta', state: 'GA', country: 'USA' },
    eventDate: future(5, 21), currentAttendees: 54, maxAttendees: 150,
    price: 0, currency: 'USD', isFree: true,
    tags: ['openmic', 'rap', 'spoken-word', 'atlanta', 'live'], skills: ['Rap', 'Vocals'] as ArtistSpecialty[],
    isPublished: true, isCancelled: false, createdAt: ts(7), updatedAt: ts(0),
  },
];

// ─── Courses ─────────────────────────────────────────────────────────────────

const COURSES: Course[] = [
  {
    id: 'course-1', instructorId: 'user-marcus',
    instructor: { uid: 'user-marcus', displayName: 'Marcus Johnson', artistName: 'MJAY', photoURL: 'https://i.pravatar.cc/200?u=marcus', specialties: ['Dance', 'Choreography'] as ArtistSpecialty[], isVerified: true },
    title: 'Hip Hop Foundations: From Zero to Cipher',
    subtitle: 'Master the fundamentals of hip hop dance with NYC\'s top choreographer',
    description: 'A comprehensive beginner course covering the history, culture, and technique behind hip hop dance. Learn foundational movements, musicality, and how to hold your own in any cipher.',
    coverImageUrl: 'https://picsum.photos/seed/hiphop-course/800/450',
    category: 'Dance' as ArtistSpecialty, level: 'beginner',
    tags: ['hiphop', 'dance', 'beginner', 'foundations', 'NYC'],
    language: 'English', price: 79, currency: 'USD', isFree: false,
    lessonsCount: 18, totalDuration: 19800, enrolledCount: 2340,
    rating: 4.9, ratingsCount: 412, status: 'published',
    createdAt: ts(180), updatedAt: ts(14),
  },
  {
    id: 'course-2', instructorId: 'user-karim',
    instructor: { uid: 'user-karim', displayName: 'Karim Hassan', artistName: 'DJ K-Flow', photoURL: 'https://i.pravatar.cc/200?u=karim', specialties: ['DJ', 'Production'] as ArtistSpecialty[], isVerified: true },
    title: 'Afrohouse Production: Dancefloor Dynamics',
    subtitle: 'Build Afrohouse and Amapiano tracks that move crowds — with DJ K-Flow',
    description: 'Learn professional production techniques for Afrohouse, Amapiano and Afrobeats from Fabric London\'s resident DJ. Covers sound design, arrangement, mixing, and release strategy.',
    coverImageUrl: 'https://picsum.photos/seed/production-course/800/450',
    category: 'Production' as ArtistSpecialty, level: 'intermediate',
    tags: ['afrohouse', 'production', 'dj', 'amapiano', 'mixing'],
    language: 'English', price: 149, currency: 'USD', isFree: false,
    lessonsCount: 24, totalDuration: 32400, enrolledCount: 1180,
    rating: 4.8, ratingsCount: 203, status: 'published',
    createdAt: ts(90), updatedAt: ts(7),
  },
  {
    id: 'course-3', instructorId: 'user-zara',
    instructor: { uid: 'user-zara', displayName: 'Zara Williams', artistName: 'ZaraW', photoURL: 'https://i.pravatar.cc/200?u=zara', specialties: ['Choreography', 'Vocals'] as ArtistSpecialty[], isVerified: true },
    title: 'Choreography Intensive: Craft Your Vision',
    subtitle: 'Advanced methods for creating, directing and presenting original dance work',
    description: 'Designed for intermediate-to-advanced dancers ready to step into the choreographer role. Covers concept development, spatial design, rehearsal direction, and performing arts presentation.',
    coverImageUrl: 'https://picsum.photos/seed/choreo-course/800/450',
    category: 'Choreography' as ArtistSpecialty, level: 'advanced',
    tags: ['choreography', 'contemporary', 'direction', 'artistry'],
    language: 'English', price: 199, currency: 'USD', isFree: false,
    lessonsCount: 16, totalDuration: 25200, enrolledCount: 640,
    rating: 5.0, ratingsCount: 98, status: 'published',
    createdAt: ts(120), updatedAt: ts(21),
  },
  {
    id: 'course-4', instructorId: 'user-zara',
    instructor: { uid: 'user-zara', displayName: 'Zara Williams', artistName: 'ZaraW', photoURL: 'https://i.pravatar.cc/200?u=zara', specialties: ['Vocals'] as ArtistSpecialty[], isVerified: true },
    title: 'Vocal Performance for Artists',
    subtitle: 'Free fundamentals for dancers, rappers and performers who want to add vocals',
    description: 'A free introductory course for performing artists who want to develop their voice. Covers breathing, projection, tone, and performance confidence for artists who don\'t come from a singing background.',
    coverImageUrl: 'https://picsum.photos/seed/vocals-course/800/450',
    category: 'Vocals' as ArtistSpecialty, level: 'all-levels',
    tags: ['vocals', 'singing', 'beginner', 'free', 'performance'],
    language: 'English', price: 0, currency: 'USD', isFree: true,
    lessonsCount: 8, totalDuration: 7200, enrolledCount: 8920,
    rating: 4.7, ratingsCount: 1340, status: 'published',
    createdAt: ts(60), updatedAt: ts(5),
  },
];

// ─── Notifications ────────────────────────────────────────────────────────────

const NOTIFICATIONS: Notification[] = [
  {
    id: 'notif-1', recipientId: 'user-demo', senderId: 'user-marcus',
    senderName: 'MJAY', senderPhotoURL: 'https://i.pravatar.cc/200?u=marcus',
    type: 'like', title: 'New like', body: 'liked your post',
    data: { postId: 'post-1' }, isRead: false, createdAt: ts(0, 0.08),
  },
  {
    id: 'notif-2', recipientId: 'user-demo', senderId: 'user-zara',
    senderName: 'ZaraW', senderPhotoURL: 'https://i.pravatar.cc/200?u=zara',
    type: 'follow', title: 'New follower', body: 'started following you',
    data: {}, isRead: false, createdAt: ts(0, 0.4),
  },
  {
    id: 'notif-3', recipientId: 'user-demo', senderId: 'user-karim',
    senderName: 'DJ K-Flow', senderPhotoURL: 'https://i.pravatar.cc/200?u=karim',
    type: 'comment', title: 'New comment', body: 'commented: "This is fire 🔥 love the energy"',
    data: { postId: 'post-2' }, isRead: false, createdAt: ts(0, 1),
  },
  {
    id: 'notif-4', recipientId: 'user-demo', senderId: 'user-andre',
    senderName: 'Dré B', senderPhotoURL: 'https://i.pravatar.cc/200?u=andre',
    type: 'collab_invite', title: 'Collaboration invite', body: 'invited you to collaborate on "Blueprint EP"',
    data: { collaborationId: 'collab-2' }, isRead: false, createdAt: ts(0, 3),
  },
  {
    id: 'notif-5', recipientId: 'user-demo', senderId: 'user-sofia',
    senderName: 'Sofia C', senderPhotoURL: 'https://i.pravatar.cc/200?u=sofia',
    type: 'like', title: 'New like', body: 'liked your post',
    data: { postId: 'post-4' }, isRead: true, createdAt: ts(0, 6),
  },
  {
    id: 'notif-6', recipientId: 'user-demo', senderId: 'user-marcus',
    senderName: 'MJAY', senderPhotoURL: 'https://i.pravatar.cc/200?u=marcus',
    type: 'mention', title: 'Mentioned you', body: 'mentioned you in a comment: "@ALEX R you should come battle"',
    data: { postId: 'post-6' }, isRead: true, createdAt: ts(1),
  },
  {
    id: 'notif-7', recipientId: 'user-demo', senderId: 'user-marcus',
    senderName: 'Rhythm Culture', senderPhotoURL: '',
    type: 'event_reminder', title: 'Event tomorrow', body: 'NYC Hip Hop Battle Championship is tomorrow at 6pm',
    data: { eventId: 'event-1' }, isRead: true, createdAt: ts(1, 8),
  },
  {
    id: 'notif-8', recipientId: 'user-demo', senderId: 'user-karim',
    senderName: 'DJ K-Flow', senderPhotoURL: 'https://i.pravatar.cc/200?u=karim',
    type: 'collab_accepted', title: 'Collaboration accepted', body: 'accepted your collab request on "Afrohouse EP"',
    data: { collaborationId: 'collab-2' }, isRead: true, createdAt: ts(2),
  },
];

// ─── Service ──────────────────────────────────────────────────────────────────

@Injectable({ providedIn: 'root' })
export class MockDataService {

  getFeedPosts(): Post[] { return [...POSTS]; }

  getProfile(uid: string): UserProfile {
    return PROFILES[uid] ?? PROFILES['user-demo'];
  }

  getPostsForUser(uid: string): Post[] {
    const userPosts = POSTS.filter(p => p.authorId === uid);
    return userPosts.length > 0
      ? userPosts
      : POSTS.slice(0, 3).map(p => ({ ...p, authorId: uid }));
  }

  getAllProfiles(): UserProfile[] { return Object.values(PROFILES); }

  getCollaborations(): Collaboration[] { return [...COLLABORATIONS]; }

  getEvents(category?: string): Event[] {
    return category
      ? EVENTS.filter(e => e.category === category)
      : [...EVENTS];
  }

  getCourses(category?: string): Course[] {
    return category && category !== 'all'
      ? COURSES.filter(c => c.category === category)
      : [...COURSES];
  }

  getNotifications(): Notification[] { return [...NOTIFICATIONS]; }

  getStories(): MockStory[] {
    return [
      { uid: 'user-demo', displayName: 'Your Story', photoURL: 'https://i.pravatar.cc/200?u=alexrivera', isVerified: false, isOwn: true },
      { uid: 'user-marcus', displayName: 'MJAY', photoURL: 'https://i.pravatar.cc/200?u=marcus', isVerified: true },
      { uid: 'user-zara', displayName: 'ZaraW', photoURL: 'https://i.pravatar.cc/200?u=zara', isVerified: true },
      { uid: 'user-karim', displayName: 'DJ K-Flow', photoURL: 'https://i.pravatar.cc/200?u=karim', isVerified: true },
      { uid: 'user-sofia', displayName: 'Sofia C', photoURL: 'https://i.pravatar.cc/200?u=sofia', isVerified: false },
      { uid: 'user-andre', displayName: 'Dré B', photoURL: 'https://i.pravatar.cc/200?u=andre', isVerified: false },
    ];
  }

  getUnreadNotificationCount(): number {
    return NOTIFICATIONS.filter(n => !n.isRead).length;
  }

  getOwnProfileUid(): string { return 'user-demo'; }
}
