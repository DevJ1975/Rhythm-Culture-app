// MockData.swift
// Demo data — swap image URLs with licensed assets before App Store submission.

import SwiftUI
import Foundation

enum MockData {

    // MARK: - Stories
    static let stories: [StoryItem] = [
        StoryItem(id: "0", username: "Your Story",     gradientColors: [Color(.systemGray4), Color(.systemGray3)],
                  imageURL: "https://i.pravatar.cc/200?img=12", isSelf: true, hasUnseenStory: false),
        StoryItem(id: "1", username: "travispayne",    gradientColors: [.purple, .pink],
                  imageURL: "https://i.pravatar.cc/200?img=3"),
        StoryItem(id: "2", username: "missy.elliott",  gradientColors: [.blue, .cyan],
                  imageURL: "https://i.pravatar.cc/200?img=47"),
        StoryItem(id: "3", username: "fik.shun",       gradientColors: [.orange, .red],
                  imageURL: "https://i.pravatar.cc/200?img=8"),
        StoryItem(id: "4", username: "laurieann.g",    gradientColors: [.red, .pink],
                  imageURL: "https://i.pravatar.cc/200?img=57"),
        StoryItem(id: "5", username: "boogaloo",       gradientColors: [.green, .teal],
                  imageURL: "https://i.pravatar.cc/200?img=15"),
        StoryItem(id: "6", username: "dj.jazzy.jeff",  gradientColors: [.yellow, .orange],
                  imageURL: "https://i.pravatar.cc/200?img=33"),
        StoryItem(id: "7", username: "taeyang",        gradientColors: [.indigo, .purple],
                  imageURL: "https://i.pravatar.cc/200?img=21"),
    ]

    // MARK: - Feed Posts
    static let posts: [Post] = [
        Post(id: "1",
             authorId: "travispayne",
             authorUsername: "travispayne",
             authorDisplayName: "Travis Payne",
             authorArtistType: .dancer,
             caption: "Rehearsals never lie. The body remembers what the mind forgets. Every rep, every count, every breath — this is the work. 💃🔥 #DanceLife #Choreographer",
             mediaURLs: ["https://picsum.photos/id/1005/800/800"],
             mediaType: .image, postType: .showcase, genre: "Pop / R&B",
             likesCount: 48200, commentsCount: 1840,
             vibeReactions: Post.VibeReactions(fire: 12400, move: 21000, vibes: 8300, respect: 5900),
             isLikedByCurrentUser: false, createdAt: Date().addingTimeInterval(-3600)),

        Post(id: "2",
             authorId: "missy.elliott",
             authorUsername: "missy.elliott",
             authorDisplayName: "Missy Elliott",
             authorArtistType: .singer,
             caption: "New era loading. Been in the studio cooking something the culture ain't ready for. Stay locked in. 🎤🎧 #HipHop #NewMusic",
             mediaURLs: ["https://picsum.photos/id/1027/800/800"],
             mediaType: .image, postType: .drop, genre: "Hip-Hop / R&B",
             likesCount: 124000, commentsCount: 5600,
             vibeReactions: Post.VibeReactions(fire: 45000, move: 18000, vibes: 32000, respect: 21000),
             isLikedByCurrentUser: true, createdAt: Date().addingTimeInterval(-7200)),

        Post(id: "3",
             authorId: "fik.shun",
             authorUsername: "fik.shun",
             authorDisplayName: "Fik-Shun",
             authorArtistType: .dancer,
             caption: "Animation is not a style — it's a language. Every pop, every wave, every freeze tells a story without a single word. 🤖✨ #Animation #StreetDance",
             mediaURLs: ["https://picsum.photos/id/1062/800/800"],
             mediaType: .image, postType: .showcase, genre: "Animation / Popping",
             likesCount: 31400, commentsCount: 920,
             vibeReactions: Post.VibeReactions(fire: 9800, move: 14200, vibes: 5100, respect: 3800),
             isLikedByCurrentUser: false, createdAt: Date().addingTimeInterval(-14400)),

        Post(id: "4",
             authorId: "laurieann.g",
             authorUsername: "laurieann.g",
             authorDisplayName: "Laurieann Gibson",
             authorArtistType: .dancer,
             caption: "I didn't choose choreography — it chose me. Every artist I've worked with has made me better. Keep creating. 🙏🎶 #Choreographer",
             mediaURLs: ["https://picsum.photos/id/1074/800/800"],
             mediaType: .image, postType: .standard, genre: "Pop / Contemporary",
             likesCount: 19700, commentsCount: 674,
             vibeReactions: Post.VibeReactions(fire: 5200, move: 8900, vibes: 3100, respect: 4700),
             isLikedByCurrentUser: false, createdAt: Date().addingTimeInterval(-21600)),

        Post(id: "5",
             authorId: "travispayne",
             authorUsername: "travispayne",
             authorDisplayName: "Travis Payne",
             authorArtistType: .dancer,
             caption: "Looking for 4 trained dancers for an upcoming world tour production. DM for details. 📩 #DancerCall #Paid #WorldTour",
             mediaURLs: ["https://picsum.photos/id/1014/800/800"],
             mediaType: .image, postType: .collab, genre: "Multi-Style",
             likesCount: 22100, commentsCount: 1230,
             vibeReactions: Post.VibeReactions(fire: 6700, move: 9400, vibes: 2800, respect: 5100),
             isLikedByCurrentUser: true, createdAt: Date().addingTimeInterval(-32400)),

        Post(id: "6",
             authorId: "boogaloo.shrimp",
             authorUsername: "boogaloo.shrimp",
             authorDisplayName: "Boogaloo Shrimp",
             authorArtistType: .dancer,
             caption: "Breakin' gave me everything. Identity, community, purpose. The culture is alive because we keep passing it down. 🔥 #Breakdance #Bboy #OG",
             mediaURLs: ["https://picsum.photos/id/1012/800/800"],
             mediaType: .image, postType: .standard, genre: "Breakdance / Hip-Hop",
             likesCount: 41800, commentsCount: 1540,
             vibeReactions: Post.VibeReactions(fire: 15200, move: 18700, vibes: 5300, respect: 9100),
             isLikedByCurrentUser: false, createdAt: Date().addingTimeInterval(-43200)),
    ]

    // MARK: - Spaces (Live Audio Rooms)
    static let spaces: [Space] = [
        Space(id: "s1", hostId: "travispayne", hostUsername: "travispayne",
              title: "The Business of Dance: Getting Paid on Tour",
              topic: "How to negotiate contracts, get touring gigs, and build a sustainable career.",
              artistType: .dancer,
              speakerUsernames: ["laurieann.g", "fik.shun", "boogaloo"],
              listenerCount: 3842, isLive: true,
              scheduledFor: nil, startedAt: Date().addingTimeInterval(-2700), createdAt: Date().addingTimeInterval(-2700)),

        Space(id: "s2", hostId: "missy.elliott", hostUsername: "missy.elliott",
              title: "Writing Hits: From Concept to Chorus",
              topic: "The songwriting process, finding your sound, and working with producers.",
              artistType: .singer,
              speakerUsernames: ["dj.jazzy.jeff", "taeyang"],
              listenerCount: 12400, isLive: true,
              scheduledFor: nil, startedAt: Date().addingTimeInterval(-5400), createdAt: Date().addingTimeInterval(-5400)),

        Space(id: "s3", hostId: "fik.shun", hostUsername: "fik.shun",
              title: "Street Dance Culture: Origins & Evolution",
              topic: "Breaking down the history — locking, popping, waacking, and what comes next.",
              artistType: .dancer,
              speakerUsernames: ["boogaloo", "laurieann.g"],
              listenerCount: 2190, isLive: true,
              scheduledFor: nil, startedAt: Date().addingTimeInterval(-1800), createdAt: Date().addingTimeInterval(-1800)),

        Space(id: "s4", hostId: "dj.jazzy.jeff", hostUsername: "dj.jazzy.jeff",
              title: "DJ Set: Live Crate Digging Session 🎧",
              topic: "Live vinyl session — call in, request tracks, talk music history.",
              artistType: .dj,
              speakerUsernames: [],
              listenerCount: 7640, isLive: true,
              scheduledFor: nil, startedAt: Date().addingTimeInterval(-900), createdAt: Date().addingTimeInterval(-900)),
    ]

    // MARK: - Masterclasses
    static let masterclasses: [Masterclass] = [
        Masterclass(id: "m1",
                    instructorId: "travispayne", instructorUsername: "travispayne",
                    instructorDisplayName: "Travis Payne",
                    instructorImageURL: "https://i.pravatar.cc/200?img=3",
                    title: "World-Class Choreography",
                    description: "Learn the methods behind some of the biggest productions in pop history. From concept to stage, Travis Payne breaks down his full choreographic process.",
                    price: 199.00, artistType: .dancer,
                    lessonCount: 18, totalDurationMinutes: 480,
                    rating: 4.9, reviewCount: 2840, enrolledCount: 14200,
                    thumbnailURL: "https://picsum.photos/id/1005/600/400",
                    tags: ["Choreography", "Pop", "Stage", "Michael Jackson"],
                    createdAt: Date().addingTimeInterval(-86400 * 30)),

        Masterclass(id: "m2",
                    instructorId: "missy.elliott", instructorUsername: "missy.elliott",
                    instructorDisplayName: "Missy Elliott",
                    instructorImageURL: "https://i.pravatar.cc/200?img=47",
                    title: "Hip-Hop Songwriting Masterclass",
                    description: "Missy Elliott shares the secrets behind 25+ years of hit-making. Learn how to write, produce, and present your music to the world.",
                    price: 149.00, artistType: .singer,
                    lessonCount: 14, totalDurationMinutes: 360,
                    rating: 4.8, reviewCount: 5100, enrolledCount: 28400,
                    thumbnailURL: "https://picsum.photos/id/1027/600/400",
                    tags: ["Songwriting", "Hip-Hop", "Production", "R&B"],
                    createdAt: Date().addingTimeInterval(-86400 * 45)),

        Masterclass(id: "m3",
                    instructorId: "fik.shun", instructorUsername: "fik.shun",
                    instructorDisplayName: "Fik-Shun",
                    instructorImageURL: "https://i.pravatar.cc/200?img=8",
                    title: "Street Dance Mastery",
                    description: "From popping to animation to freestyle — Fik-Shun breaks down street dance from the ground up with drills, concepts, and culture.",
                    price: 99.00, artistType: .dancer,
                    lessonCount: 22, totalDurationMinutes: 540,
                    rating: 4.9, reviewCount: 3620, enrolledCount: 19800,
                    thumbnailURL: "https://picsum.photos/id/1062/600/400",
                    tags: ["Popping", "Animation", "Freestyle", "Street Dance"],
                    createdAt: Date().addingTimeInterval(-86400 * 20)),

        Masterclass(id: "m4",
                    instructorId: "laurieann.g", instructorUsername: "laurieann.g",
                    instructorDisplayName: "Laurieann Gibson",
                    instructorImageURL: "https://i.pravatar.cc/200?img=57",
                    title: "The Art of Performance Directing",
                    description: "How do you turn a great song into an unforgettable show? Laurieann Gibson — director for Gaga, Beyoncé, Nicki — teaches you how.",
                    price: 179.00, artistType: .dancer,
                    lessonCount: 16, totalDurationMinutes: 420,
                    rating: 4.7, reviewCount: 1940, enrolledCount: 9400,
                    thumbnailURL: "https://picsum.photos/id/1074/600/400",
                    tags: ["Directing", "Performance", "Stage Production", "Pop"],
                    createdAt: Date().addingTimeInterval(-86400 * 60)),

        Masterclass(id: "m5",
                    instructorId: "boogaloo.shrimp", instructorUsername: "boogaloo.shrimp",
                    instructorDisplayName: "Boogaloo Shrimp",
                    instructorImageURL: "https://i.pravatar.cc/200?img=15",
                    title: "The History & Technique of Breakdance",
                    description: "The OG of breaking teaches you the roots, the moves, and the culture of hip-hop's most iconic dance form.",
                    price: 79.00, artistType: .dancer,
                    lessonCount: 20, totalDurationMinutes: 390,
                    rating: 5.0, reviewCount: 4200, enrolledCount: 11600,
                    thumbnailURL: "https://picsum.photos/id/1012/600/400",
                    tags: ["Breakdance", "Hip-Hop", "Bboy", "Footwork"],
                    createdAt: Date().addingTimeInterval(-86400 * 90)),

        Masterclass(id: "m6",
                    instructorId: "dj.jazzy.jeff", instructorUsername: "dj.jazzy.jeff",
                    instructorDisplayName: "DJ Jazzy Jeff",
                    instructorImageURL: "https://i.pravatar.cc/200?img=33",
                    title: "DJ Mastery: From Bedroom to Main Stage",
                    description: "Grammy-winning DJ Jazzy Jeff teaches mixing, scratching, reading a crowd, and building a career behind the decks.",
                    price: 129.00, artistType: .dj,
                    lessonCount: 24, totalDurationMinutes: 600,
                    rating: 4.9, reviewCount: 6800, enrolledCount: 32100,
                    thumbnailURL: "https://picsum.photos/id/325/600/400",
                    tags: ["DJ", "Mixing", "Scratching", "Hip-Hop"],
                    createdAt: Date().addingTimeInterval(-86400 * 15)),
    ]

    // MARK: - Store Items
    static let storeItems: [StoreItem] = [
        StoreItem(id: "st1", sellerId: "dj.jazzy.jeff", sellerUsername: "dj.jazzy.jeff",
                  sellerDisplayName: "DJ Jazzy Jeff", sellerArtistType: .dj,
                  sellerTier: .elite,
                  type: .beat, title: "Soul Bounce (Prod. Jazzy Jeff)",
                  description: "Soulful hip-hop banger with live bass, vintage keys, and hard-hitting 808s. Perfect for conscious rap or R&B crossover.",
                  price: 49.99, licenseType: .nonExclusive,
                  genre: "Hip-Hop / Soul", bpm: 92, keySignature: "F Minor",
                  tags: ["Hip-Hop", "Soul", "Boom Bap", "Vintage"],
                  thumbnailURL: "https://picsum.photos/id/325/400/400",
                  purchaseCount: 847, playCount: 24300, createdAt: Date().addingTimeInterval(-86400 * 10)),

        StoreItem(id: "st2", sellerId: "dj.jazzy.jeff", sellerUsername: "dj.jazzy.jeff",
                  sellerDisplayName: "DJ Jazzy Jeff", sellerArtistType: .dj,
                  sellerTier: .elite,
                  type: .beat, title: "Midnight Frequency (Exclusive)",
                  description: "Dark, atmospheric trap beat with cinematic strings and deep 808 rolls. Exclusive license — yours alone.",
                  price: 599.00, licenseType: .exclusive,
                  genre: "Trap / Cinematic", bpm: 140, keySignature: "B Minor",
                  tags: ["Trap", "Dark", "Cinematic", "808"],
                  thumbnailURL: "https://picsum.photos/id/338/400/400",
                  purchaseCount: 1, playCount: 8940, createdAt: Date().addingTimeInterval(-86400 * 5)),

        StoreItem(id: "st3", sellerId: "taeyang", sellerUsername: "taeyang",
                  sellerDisplayName: "Taeyang", sellerArtistType: .producer,
                  sellerTier: .established,
                  type: .beat, title: "Afrobeats Fire Vol.1",
                  description: "High-energy Afrobeats production with percussive layers, catchy melodics, and dance-floor ready groove.",
                  price: 39.99, licenseType: .nonExclusive,
                  genre: "Afrobeats", bpm: 104, keySignature: "G Major",
                  tags: ["Afrobeats", "Dance", "Groove", "Energy"],
                  thumbnailURL: "https://picsum.photos/id/342/400/400",
                  purchaseCount: 412, playCount: 15600, createdAt: Date().addingTimeInterval(-86400 * 7)),

        StoreItem(id: "st4", sellerId: "taeyang", sellerUsername: "taeyang",
                  sellerDisplayName: "Taeyang", sellerArtistType: .producer,
                  sellerTier: .established,
                  type: .beat, title: "R&B Unlimited Pack (3 Beats)",
                  description: "Three smooth R&B beats with unlimited license. Use on streaming, music videos, live shows — no royalties owed.",
                  price: 249.00, licenseType: .unlimited,
                  genre: "R&B", bpm: 78, keySignature: "D Major",
                  tags: ["R&B", "Smooth", "Unlimited", "Pack"],
                  thumbnailURL: "https://picsum.photos/id/347/400/400",
                  purchaseCount: 234, playCount: 9800, createdAt: Date().addingTimeInterval(-86400 * 14)),

        StoreItem(id: "st5", sellerId: "missy.elliott", sellerUsername: "missy.elliott",
                  sellerDisplayName: "Missy Elliott", sellerArtistType: .singer,
                  sellerTier: .elite,
                  type: .musicTrack, title: "Level Up (Demo Version)",
                  description: "Exclusive demo track — unmastered vocal take over a custom production. Collector's item for fans and producers.",
                  price: 9.99, licenseType: .free,
                  genre: "Hip-Hop / R&B", bpm: nil, keySignature: nil,
                  tags: ["Demo", "Collector", "Hip-Hop", "R&B"],
                  thumbnailURL: "https://picsum.photos/id/1027/400/400",
                  purchaseCount: 4820, playCount: 98400, createdAt: Date().addingTimeInterval(-86400 * 3)),

        StoreItem(id: "st6", sellerId: "boogaloo.shrimp", sellerUsername: "boogaloo.shrimp",
                  sellerDisplayName: "Boogaloo Shrimp", sellerArtistType: .dancer,
                  sellerTier: .elite,
                  type: .sample, title: "Break Culture Sample Pack Vol.1",
                  description: "50+ hand-curated breakbeat samples, drum breaks, and classic hip-hop loops from the archives. Cleared for commercial use.",
                  price: 29.99, licenseType: .unlimited,
                  genre: "Breakbeat / Hip-Hop", bpm: nil, keySignature: nil,
                  tags: ["Samples", "Breakbeat", "Hip-Hop", "Loops", "Classic"],
                  thumbnailURL: "https://picsum.photos/id/1012/400/400",
                  purchaseCount: 1840, playCount: 31200, createdAt: Date().addingTimeInterval(-86400 * 20)),

        StoreItem(id: "st7", sellerId: "laurieann.g", sellerUsername: "laurieann.g",
                  sellerDisplayName: "Laurieann Gibson", sellerArtistType: .dancer,
                  sellerTier: .established,
                  type: .preset, title: "Stage Production Starter Kit",
                  description: "Templates, cue sheets, rehearsal schedules, and production documents used in real arena tours. Digital download.",
                  price: 49.99, licenseType: .unlimited,
                  genre: "Production", bpm: nil, keySignature: nil,
                  tags: ["Production", "Templates", "Tour", "Stage"],
                  thumbnailURL: "https://picsum.photos/id/1074/400/400",
                  purchaseCount: 632, playCount: 12800, createdAt: Date().addingTimeInterval(-86400 * 12)),

        StoreItem(id: "st8", sellerId: "travispayne", sellerUsername: "travispayne",
                  sellerDisplayName: "Travis Payne", sellerArtistType: .dancer,
                  sellerTier: .upAndComing,
                  type: .merch, title: "Travis Payne Signature Tee",
                  description: "Limited run signature tee — heavyweight cotton, artist-designed graphic on the back, embroidered logo on chest.",
                  price: 45.00, licenseType: nil,
                  genre: nil, bpm: nil, keySignature: nil,
                  tags: ["Merch", "Limited", "Tee", "Streetwear"],
                  thumbnailURL: "https://picsum.photos/id/1005/400/400",
                  purchaseCount: 72, playCount: 0, createdAt: Date().addingTimeInterval(-86400 * 2)),
    ]

    // MARK: - Live Streams
    static let liveStreams: [LiveStream] = [
        LiveStream(id: "l1", hostId: "travispayne", hostUsername: "travispayne",
                   hostDisplayName: "Travis Payne",
                   hostImageURL: "https://i.pravatar.cc/200?img=3",
                   title: "Rehearsal Day — World Tour Prep 🌍",
                   viewerCount: 14820, isActive: true,
                   startedAt: Date().addingTimeInterval(-1800)),

        LiveStream(id: "l2", hostId: "dj.jazzy.jeff", hostUsername: "dj.jazzy.jeff",
                   hostDisplayName: "DJ Jazzy Jeff",
                   hostImageURL: "https://i.pravatar.cc/200?img=33",
                   title: "Live DJ Set — Friday Night Frequencies 🎧",
                   viewerCount: 28400, isActive: true,
                   startedAt: Date().addingTimeInterval(-3600)),
    ]

    // MARK: - Battles
    static let challenges: [Challenge] = [
        Challenge(id: "c1",
                  title: "Best Popping Routine — 60 Seconds",
                  description: "Show your cleanest popping, waving, or animation sequence. 60 sec max. Any music.",
                  artistType: .dancer, genre: "Popping / Animation",
                  creatorId: "fik.shun", creatorUsername: "fik.shun", votesA: 14700,
                  challengerId: "travispayne", challengerUsername: "travispayne", votesB: 12400,
                  submissionCount: 842, deadline: Date().addingTimeInterval(172_800),
                  createdAt: Date().addingTimeInterval(-86400)),

        Challenge(id: "c2",
                  title: "Best Freestyle Cypher — Open Style",
                  description: "Pure freestyle. No choreography. Just you and the music. 30 seconds.",
                  artistType: .dancer, genre: "Freestyle / Open Style",
                  creatorId: "laurieann.g", creatorUsername: "laurieann.g", votesA: 8900,
                  challengerId: "boogaloo.shrimp", challengerUsername: "boogaloo.shrimp", votesB: 11200,
                  submissionCount: 563, deadline: Date().addingTimeInterval(86_400),
                  createdAt: Date().addingTimeInterval(-43200)),

        Challenge(id: "c3",
                  title: "Open Vocal Battle — No AutoTune",
                  description: "Raw voice only. Acapella or live instrument. Show what you were born with.",
                  artistType: .singer, genre: "R&B / Soul",
                  creatorId: "missy.elliott", creatorUsername: "missy.elliott", votesA: 0,
                  challengerId: nil, challengerUsername: nil, votesB: 0,
                  submissionCount: 0, deadline: Date().addingTimeInterval(259_200),
                  createdAt: Date().addingTimeInterval(-3600)),
    ]

    // MARK: - Collab Board
    static let collabRequests: [CollabRequest] = [
        CollabRequest(id: "r1", creatorId: "travispayne", creatorUsername: "travispayne",
                      creatorArtistType: .dancer,
                      title: "World Tour Dancer Call — 4 Spots",
                      description: "Seeking highly trained dancers for a major world tour. Must be versatile across hip-hop, contemporary, and ballroom. Competitive pay, full benefits.",
                      projectType: "World Tour", lookingFor: [.dancer, .videographer],
                      genre: "Pop / R&B", location: "Los Angeles, CA",
                      isRemoteFriendly: false, applicantsCount: 187,
                      createdAt: Date().addingTimeInterval(-7200)),

        CollabRequest(id: "r2", creatorId: "missy.elliott", creatorUsername: "missy.elliott",
                      creatorArtistType: .singer,
                      title: "Music Video — Need Choreographer",
                      description: "New single dropping next month. Need a choreographer for high-energy hip-hop with a futuristic edge.",
                      projectType: "Music Video", lookingFor: [.dancer],
                      genre: "Hip-Hop", location: "New York, NY",
                      isRemoteFriendly: false, applicantsCount: 312,
                      createdAt: Date().addingTimeInterval(-21600)),

        CollabRequest(id: "r3", creatorId: "fik.shun", creatorUsername: "fik.shun",
                      creatorArtistType: .dancer,
                      title: "Online Dance Masterclass — Co-Host",
                      description: "Launching a paid online masterclass series on street dance. Looking for another elite dancer to co-host. Revenue share.",
                      projectType: "Online Course", lookingFor: [.dancer, .videographer],
                      genre: "Street Dance", location: "Remote",
                      isRemoteFriendly: true, applicantsCount: 94,
                      createdAt: Date().addingTimeInterval(-43200)),
    ]

    // MARK: - Auditions
    static let auditions: [Audition] = [
        Audition(id: "a1",
                 posterId: "travispayne", posterUsername: "travispayne",
                 posterDisplayName: "Travis Payne", posterArtistType: .dancer,
                 posterImageURL: "https://i.pravatar.cc/200?img=3",
                 projectName: "Global Rhythm World Tour 2025",
                 projectType: .worldTour,
                 title: "Principal Dancers — 6 Positions Open",
                 description: "World-class choreographer Travis Payne is casting principal dancers for a 47-city world tour. Must have strong technique in hip-hop, contemporary, and ballroom. Previous touring experience preferred but not required. Compensation package includes salary, per diem, travel, and accommodations.",
                 lookingFor: [.dancer],
                 compensation: .paidTravel, compensationAmount: "$1,200/week + full travel",
                 location: "Los Angeles, CA",
                 isRemoteFriendly: false,
                 deadline: Date().addingTimeInterval(86_400 * 5),
                 submissionCount: 284,
                 createdAt: Date().addingTimeInterval(-86400)),

        Audition(id: "a2",
                 posterId: "laurieann.g", posterUsername: "laurieann.g",
                 posterDisplayName: "Laurieann Gibson", posterArtistType: .dancer,
                 posterImageURL: "https://i.pravatar.cc/200?img=57",
                 projectName: "Rhythm & Soul — Original Broadway Production",
                 projectType: .broadway,
                 title: "Ensemble Cast — Dancers Who Sing",
                 description: "Casting for an original Broadway-bound production exploring the roots of R&B, soul, and hip-hop. Looking for dancers with strong vocal ability. All ethnicities, all body types. Union and non-union welcome. Equity contract available.",
                 lookingFor: [.dancer, .singer],
                 compensation: .paid, compensationAmount: "Equity contract — $1,800/week",
                 location: "New York, NY",
                 isRemoteFriendly: false,
                 deadline: Date().addingTimeInterval(86_400 * 2),
                 submissionCount: 521,
                 createdAt: Date().addingTimeInterval(-86400 * 3)),

        Audition(id: "a3",
                 posterId: "missy.elliott", posterUsername: "missy.elliott",
                 posterDisplayName: "Missy Elliott", posterArtistType: .singer,
                 posterImageURL: "https://i.pravatar.cc/200?img=47",
                 projectName: "Level Up — New Single Music Video",
                 projectType: .musicVideo,
                 title: "Featured Dancers — 8 Spots",
                 description: "Missy Elliott is casting 8 featured dancers for an upcoming major music video. Looking for high-energy, personality-driven performers comfortable in front of camera. Futuristic hip-hop aesthetic. 2-day shoot in NYC. All travel covered.",
                 lookingFor: [.dancer],
                 compensation: .paidTravel, compensationAmount: "$500/day + travel",
                 location: "New York, NY",
                 isRemoteFriendly: false,
                 deadline: Date().addingTimeInterval(86_400 * 1),
                 submissionCount: 947,
                 createdAt: Date().addingTimeInterval(-86400 * 2)),

        Audition(id: "a4",
                 posterId: "dj.jazzy.jeff", posterUsername: "dj.jazzy.jeff",
                 posterDisplayName: "DJ Jazzy Jeff", posterArtistType: .dj,
                 posterImageURL: "https://i.pravatar.cc/200?img=33",
                 projectName: "A Touch of Jazz Festival 2025",
                 projectType: .festival,
                 title: "Opening Act — Emerging Artists",
                 description: "DJ Jazzy Jeff's annual A Touch of Jazz Festival is accepting submissions for opening act slots. Seeking emerging singers, rappers, and live bands with original material. This is a paid, professional stage — not a showcase. Previous performance experience required.",
                 lookingFor: [.singer, .rapper, .dancer],
                 compensation: .paid, compensationAmount: "$800 flat + promotion",
                 location: "Philadelphia, PA",
                 isRemoteFriendly: false,
                 deadline: Date().addingTimeInterval(86_400 * 14),
                 submissionCount: 163,
                 createdAt: Date().addingTimeInterval(-86400 * 5)),
    ]

    // MARK: - Current User
    static let currentUser = AppUser(
        id: "travispayne",
        username: "travispayne",
        displayName: "Travis Payne",
        email: "travis@travispayne.com",
        profileImageURL: "https://i.pravatar.cc/400?img=3",
        bio: "Choreographer. Director. Storyteller. Michael Jackson • Lady Gaga • Beyoncé 🎭",
        artistType: .dancer,
        genres: ["Contemporary", "Hip-Hop", "Pop", "R&B"],
        location: "Los Angeles, CA",
        followersCount: 284000,
        followingCount: 1240,
        postsCount: 318
    )

    // MARK: - All Mock Users
    static let allUsers: [AppUser] = [
        currentUser,
        AppUser(id: "missy.elliott", username: "missy.elliott", displayName: "Missy Elliott",
                email: "missy@rc.com", profileImageURL: "https://i.pravatar.cc/400?img=47",
                bio: "Hip-Hop icon. Grammy Award winner. Songwriter. Producer. Director. 🎤",
                artistType: .singer, genres: ["Hip-Hop", "R&B", "Pop"],
                location: "Portsmouth, VA", followersCount: 1_240_000, followingCount: 820, postsCount: 94),
        AppUser(id: "fik.shun", username: "fik.shun", displayName: "Fik-Shun",
                email: "fik@rc.com", profileImageURL: "https://i.pravatar.cc/400?img=8",
                bio: "SYTYCD Season 10 Champion 🏆 Animation • Popping • Freestyle. LA based.",
                artistType: .dancer, genres: ["Popping", "Animation", "Freestyle"],
                location: "Los Angeles, CA", followersCount: 482000, followingCount: 1100, postsCount: 227),
        AppUser(id: "laurieann.g", username: "laurieann.g", displayName: "Laurieann Gibson",
                email: "laurieann@rc.com", profileImageURL: "https://i.pravatar.cc/400?img=57",
                bio: "Choreographer • Director • Creative Visionary. Lady Gaga • Katy Perry • Nicki Minaj 🎬",
                artistType: .dancer, genres: ["Pop", "Contemporary", "Commercial"],
                location: "New York, NY", followersCount: 318000, followingCount: 940, postsCount: 156),
        AppUser(id: "boogaloo.shrimp", username: "boogaloo.shrimp", displayName: "Boogaloo Shrimp",
                email: "boogaloo@rc.com", profileImageURL: "https://i.pravatar.cc/400?img=15",
                bio: "OG. Breakin' legend. Turbo in Breakin' (1984). Culture keeper. 🔥",
                artistType: .dancer, genres: ["Breakdance", "Hip-Hop", "Bboying"],
                location: "Los Angeles, CA", followersCount: 724000, followingCount: 310, postsCount: 412),
        AppUser(id: "dj.jazzy.jeff", username: "dj.jazzy.jeff", displayName: "DJ Jazzy Jeff",
                email: "jeff@rc.com", profileImageURL: "https://i.pravatar.cc/400?img=33",
                bio: "Grammy Award winning DJ & Producer. Philly. The Fresh Prince era never ended. 🎧",
                artistType: .dj, genres: ["Hip-Hop", "Soul", "R&B", "Funk"],
                location: "Philadelphia, PA", followersCount: 891000, followingCount: 640, postsCount: 203),
        AppUser(id: "taeyang", username: "taeyang", displayName: "Taeyang",
                email: "taeyang@rc.com", profileImageURL: "https://i.pravatar.cc/400?img=21",
                bio: "Producer. Beatmaker. Sound Architect. Afrobeats meets R&B 🎹",
                artistType: .producer, genres: ["Afrobeats", "R&B", "Trap", "Soul"],
                location: "Atlanta, GA", followersCount: 156000, followingCount: 880, postsCount: 88),
    ]

    static func user(forId id: String) -> AppUser? {
        allUsers.first { $0.id == id }
    }

    // MARK: - Mock Comments
    static func comments(for postId: String) -> [Comment] {
        let pool: [Comment] = [
            Comment(id: "cmt1", authorId: "missy.elliott", authorUsername: "missy.elliott",
                    authorImageURL: "https://i.pravatar.cc/200?img=47",
                    text: "This is absolutely fire 🔥 You already know!", likesCount: 4820,
                    isLikedByCurrentUser: false, createdAt: Date().addingTimeInterval(-1800)),
            Comment(id: "cmt2", authorId: "fik.shun", authorUsername: "fik.shun",
                    authorImageURL: "https://i.pravatar.cc/200?img=8",
                    text: "The way you move through the space — unreal bro 🙌", likesCount: 1240,
                    isLikedByCurrentUser: true, createdAt: Date().addingTimeInterval(-3600)),
            Comment(id: "cmt3", authorId: "boogaloo.shrimp", authorUsername: "boogaloo.shrimp",
                    authorImageURL: "https://i.pravatar.cc/200?img=15",
                    text: "Respect from the OG. The culture is in good hands 💯", likesCount: 3100,
                    isLikedByCurrentUser: false, createdAt: Date().addingTimeInterval(-7200)),
            Comment(id: "cmt4", authorId: "laurieann.g", authorUsername: "laurieann.g",
                    authorImageURL: "https://i.pravatar.cc/200?img=57",
                    text: "We need to work together ASAP. Seriously. 📩", likesCount: 890,
                    isLikedByCurrentUser: false, createdAt: Date().addingTimeInterval(-10800)),
            Comment(id: "cmt5", authorId: "dj.jazzy.jeff", authorUsername: "dj.jazzy.jeff",
                    authorImageURL: "https://i.pravatar.cc/200?img=33",
                    text: "Put me on the remix 🎧🎧🎧", likesCount: 2400,
                    isLikedByCurrentUser: true, createdAt: Date().addingTimeInterval(-14400)),
            Comment(id: "cmt6", authorId: "taeyang", authorUsername: "taeyang",
                    authorImageURL: "https://i.pravatar.cc/200?img=21",
                    text: "Got a beat that would go crazy over this energy. Slide in the DMs 🎹", likesCount: 560,
                    isLikedByCurrentUser: false, createdAt: Date().addingTimeInterval(-18000)),
        ]
        // Shuffle based on postId for variety across posts
        let seed = abs(postId.hashValue) % pool.count
        return Array(pool.dropFirst(seed) + pool.prefix(seed))
    }

    // MARK: - Mock Notifications
    struct MockNotification: Identifiable {
        let id: String
        let type: NotifType
        let actorUsername: String
        let actorImageURL: String
        let message: String
        let thumbnailURL: String?
        let isRead: Bool
        let createdAt: Date

        enum NotifType { case like, comment, follow, battleVote, collabApply, spaceInvite }
    }

    static let notifications: [MockNotification] = [
        MockNotification(id: "n1", type: .like, actorUsername: "missy.elliott",
                         actorImageURL: "https://i.pravatar.cc/200?img=47",
                         message: "missy.elliott liked your post.", thumbnailURL: "https://picsum.photos/id/1005/100/100",
                         isRead: false, createdAt: Date().addingTimeInterval(-120)),
        MockNotification(id: "n2", type: .follow, actorUsername: "dj.jazzy.jeff",
                         actorImageURL: "https://i.pravatar.cc/200?img=33",
                         message: "dj.jazzy.jeff started following you.", thumbnailURL: nil,
                         isRead: false, createdAt: Date().addingTimeInterval(-480)),
        MockNotification(id: "n3", type: .comment, actorUsername: "fik.shun",
                         actorImageURL: "https://i.pravatar.cc/200?img=8",
                         message: "fik.shun commented: \"The way you move through the space — unreal bro 🙌\"",
                         thumbnailURL: "https://picsum.photos/id/1014/100/100",
                         isRead: false, createdAt: Date().addingTimeInterval(-900)),
        MockNotification(id: "n4", type: .battleVote, actorUsername: "boogaloo.shrimp",
                         actorImageURL: "https://i.pravatar.cc/200?img=15",
                         message: "boogaloo.shrimp voted for you in Best Popping Routine.", thumbnailURL: nil,
                         isRead: false, createdAt: Date().addingTimeInterval(-3600)),
        MockNotification(id: "n5", type: .collabApply, actorUsername: "laurieann.g",
                         actorImageURL: "https://i.pravatar.cc/200?img=57",
                         message: "laurieann.g applied to your World Tour Dancer Call.", thumbnailURL: nil,
                         isRead: true, createdAt: Date().addingTimeInterval(-7200)),
        MockNotification(id: "n6", type: .like, actorUsername: "taeyang",
                         actorImageURL: "https://i.pravatar.cc/200?img=21",
                         message: "taeyang liked your post.", thumbnailURL: "https://picsum.photos/id/1027/100/100",
                         isRead: true, createdAt: Date().addingTimeInterval(-14400)),
        MockNotification(id: "n7", type: .spaceInvite, actorUsername: "missy.elliott",
                         actorImageURL: "https://i.pravatar.cc/200?img=47",
                         message: "missy.elliott invited you to speak in Writing Hits: From Concept to Chorus.", thumbnailURL: nil,
                         isRead: true, createdAt: Date().addingTimeInterval(-28800)),
        MockNotification(id: "n8", type: .follow, actorUsername: "fik.shun",
                         actorImageURL: "https://i.pravatar.cc/200?img=8",
                         message: "fik.shun started following you.", thumbnailURL: nil,
                         isRead: true, createdAt: Date().addingTimeInterval(-86400)),
    ]

    // MARK: - Helpers
    static let avatarImageIDs = [3, 8, 12, 15, 21, 25, 33, 36, 44, 47, 51, 57, 60, 64, 68]

    static func avatarURL(_ seed: String) -> String {
        let index = abs(seed.hashValue) % avatarImageIDs.count
        return "https://i.pravatar.cc/200?img=\(avatarImageIDs[index])"
    }

    static let peoplePhotoIDs = [1005, 1012, 1014, 1025, 1027, 1032, 1047, 1062, 1074, 1083,
                                  338, 342, 347, 349, 351, 355, 365, 375, 382, 399]

    /// Derives a seller's platform tier from their cumulative store sales.
    /// Returns nil if the user has no store items.
    static func sellerTier(forUserId userId: String) -> SellerTier? {
        let items = storeItems.filter { $0.sellerId == userId }
        guard !items.isEmpty else { return nil }
        // Use the tier stored on their items (all items for one seller share the same tier)
        return items.first?.sellerTier
    }

    static func gridImageURL(index: Int) -> String {
        let photoID = peoplePhotoIDs[index % peoplePhotoIDs.count]
        return "https://picsum.photos/id/\(photoID)/400/400"
    }

    // MARK: - Coaching Listings
    static let coachingListings: [CoachingListing] = [
        CoachingListing(
            id: "cl1", sellerId: "travispayne",
            sellerUsername: "travispayne", sellerDisplayName: "Travis Payne",
            sellerImageURL: "https://i.pravatar.cc/200?img=3",
            sellerArtistType: .dancer,
            title: "Elite Choreography Sessions",
            description: "Work directly with Travis Payne — choreographer to Michael Jackson, Lady Gaga, and Beyoncé. Private sessions are tailored to your level, whether you're an emerging dancer or a touring professional looking to level up your craft.",
            styleTags: ["Contemporary", "Pop", "Hip-Hop", "Ballroom", "Stage Performance"],
            formats: [
                CoachingFormat(id: "cf1a", type: .privateSession, price: 350, durationMinutes: 60, groupCapacity: nil),
                CoachingFormat(id: "cf1b", type: .group,          price: 125, durationMinutes: 90, groupCapacity: 10),
                CoachingFormat(id: "cf1c", type: .recorded,       price: 79,  durationMinutes: nil, groupCapacity: nil),
            ],
            thumbnailURL: "https://picsum.photos/id/1005/600/400",
            verifiedCredits: ["Michael Jackson — This Is It", "Lady Gaga — Born This Way Ball", "Beyoncé — On the Run Tour II", "Janet Jackson — State of the World Tour"],
            rating: 5.0, reviewCount: 1840, totalStudents: 4200,
            isActive: true, createdAt: Date().addingTimeInterval(-86400 * 45)),

        CoachingListing(
            id: "cl2", sellerId: "fik.shun",
            sellerUsername: "fik.shun", sellerDisplayName: "Fik-Shun",
            sellerImageURL: "https://i.pravatar.cc/200?img=8",
            sellerArtistType: .dancer,
            title: "Street Dance & Animation Coaching",
            description: "SYTYCD Season 10 winner and master animator Fik-Shun breaks down the mechanics of popping, waving, tutting, and freestyle in a way no one else can. From zero foundation to battle-ready in 8 sessions.",
            styleTags: ["Popping", "Animation", "Tutting", "Freestyle", "Street Dance"],
            formats: [
                CoachingFormat(id: "cf2a", type: .privateSession, price: 200, durationMinutes: 60,  groupCapacity: nil),
                CoachingFormat(id: "cf2b", type: .group,          price: 85,  durationMinutes: 120, groupCapacity: 15),
                CoachingFormat(id: "cf2c", type: .recorded,       price: 49,  durationMinutes: nil, groupCapacity: nil),
            ],
            thumbnailURL: "https://picsum.photos/id/1062/600/400",
            verifiedCredits: ["SYTYCD Season 10 — Winner", "World of Dance", "Nick Cannon Presents", "Various World Battle Stages"],
            rating: 4.9, reviewCount: 3210, totalStudents: 9800,
            isActive: true, createdAt: Date().addingTimeInterval(-86400 * 30)),

        CoachingListing(
            id: "cl3", sellerId: "boogaloo.shrimp",
            sellerUsername: "boogaloo.shrimp", sellerDisplayName: "Boogaloo Shrimp",
            sellerImageURL: "https://i.pravatar.cc/200?img=15",
            sellerArtistType: .dancer,
            title: "Breakdance Fundamentals & History",
            description: "Learn breakdance from one of the original pioneers. Boogaloo Shrimp teaches the foundational elements of bboy culture — footwork, freezes, power moves, and the mentality of the cipher — with sessions for all levels.",
            styleTags: ["Breakdance", "Bboy", "Footwork", "Power Moves", "Hip-Hop Culture"],
            formats: [
                CoachingFormat(id: "cf3a", type: .group,    price: 65,  durationMinutes: 90, groupCapacity: 20),
                CoachingFormat(id: "cf3b", type: .recorded, price: 39,  durationMinutes: nil, groupCapacity: nil),
            ],
            thumbnailURL: "https://picsum.photos/id/1012/600/400",
            verifiedCredits: ["Breakin' — Film (1984)", "Breakin' 2: Electric Boogaloo", "Michael Jackson — World Tours", "Numerous International Dance Festivals"],
            rating: 4.8, reviewCount: 2640, totalStudents: 7100,
            isActive: true, createdAt: Date().addingTimeInterval(-86400 * 60)),

        CoachingListing(
            id: "cl4", sellerId: "laurieann.g",
            sellerUsername: "laurieann.g", sellerDisplayName: "Laurieann Gibson",
            sellerImageURL: "https://i.pravatar.cc/200?img=57",
            sellerArtistType: .dancer,
            title: "Performance Artistry & Stage Presence",
            description: "Laurieann Gibson — director and choreographer for Lady Gaga, Beyoncé, Nicki Minaj, and more — teaches you how to own a stage. Sessions focus on performance quality, audience connection, and emotional storytelling through movement.",
            styleTags: ["Performance", "Stage Presence", "Contemporary", "Pop", "Theatrical"],
            formats: [
                CoachingFormat(id: "cf4a", type: .privateSession, price: 300, durationMinutes: 75,  groupCapacity: nil),
                CoachingFormat(id: "cf4b", type: .recorded,       price: 69,  durationMinutes: nil, groupCapacity: nil),
            ],
            thumbnailURL: "https://picsum.photos/id/1074/600/400",
            verifiedCredits: ["Lady Gaga — Monster Ball Tour", "Beyoncé — Dangerously in Love Era", "Nicki Minaj — Pink Friday Tour", "BET, MTV, Grammy performances"],
            rating: 4.9, reviewCount: 1420, totalStudents: 3600,
            isActive: true, createdAt: Date().addingTimeInterval(-86400 * 20)),
    ]

    // MARK: - Consulting Listings
    static let consultingListings: [ConsultingListing] = [
        ConsultingListing(
            id: "co1", sellerId: "travispayne",
            sellerUsername: "travispayne", sellerDisplayName: "Travis Payne",
            sellerImageURL: "https://i.pravatar.cc/200?img=3",
            sellerArtistType: .dancer,
            title: "Concert Production & Artistic Direction",
            tagline: "From concept to curtain call — I build shows that define eras.",
            specialties: ["World Tour", "Concert Production", "Music Video", "Brand Campaign", "Live Event"],
            scopeStatement: "I direct the full artistic vision of a production: choreography integration, visual storytelling, stage design collaboration, and performer coaching. I do not manage logistics, crew hiring, or venue contracting.",
            dayRate: 5000, projectMinimum: 25000,
            retainerAvailable: true, retainerRateMonthly: 18000,
            availabilityStatus: .limited,
            bookedThrough: Date().addingTimeInterval(86400 * 45),
            pastProjects: [
                PastProject(id: "pp1a", name: "This Is It",                  artist: "Michael Jackson", year: 2009, role: "Co-Director & Choreographer"),
                PastProject(id: "pp1b", name: "Born This Way Ball",           artist: "Lady Gaga",       year: 2012, role: "Artistic Director"),
                PastProject(id: "pp1c", name: "On the Run Tour II",           artist: "Beyoncé",         year: 2018, role: "Creative Consultant"),
                PastProject(id: "pp1d", name: "State of the World Tour",      artist: "Janet Jackson",   year: 2017, role: "Choreography Director"),
            ],
            showreelURL: nil,
            portfolioURLs: ["https://picsum.photos/id/1005/600/400", "https://picsum.photos/id/1014/600/400"],
            isActive: true, createdAt: Date().addingTimeInterval(-86400 * 90)),

        ConsultingListing(
            id: "co2", sellerId: "laurieann.g",
            sellerUsername: "laurieann.g", sellerDisplayName: "Laurieann Gibson",
            sellerImageURL: "https://i.pravatar.cc/200?img=57",
            sellerArtistType: .dancer,
            title: "Creative Direction & Choreography Consulting",
            tagline: "I make artists iconic. That's the job.",
            specialties: ["Music Video", "Broadway", "Brand Campaign", "TV Performance", "Live Event"],
            scopeStatement: "I provide full creative direction including movement language, visual concept, wardrobe direction, and performance coaching. I do not produce or budget productions and do not book crew.",
            dayRate: 4000, projectMinimum: 20000,
            retainerAvailable: false, retainerRateMonthly: nil,
            availabilityStatus: .open,
            bookedThrough: nil,
            pastProjects: [
                PastProject(id: "pp2a", name: "Monster Ball Tour",            artist: "Lady Gaga",         year: 2009, role: "Choreographer & Creative Director"),
                PastProject(id: "pp2b", name: "Pink Friday Tour",             artist: "Nicki Minaj",       year: 2012, role: "Creative Director"),
                PastProject(id: "pp2c", name: "Dangerously in Love era",      artist: "Beyoncé",           year: 2003, role: "Choreographer"),
                PastProject(id: "pp2d", name: "Rhythm & Soul Broadway Dev.",  artist: "Original Work",     year: 2023, role: "Director & Choreographer"),
            ],
            showreelURL: nil,
            portfolioURLs: ["https://picsum.photos/id/1074/600/400", "https://picsum.photos/id/1025/600/400"],
            isActive: true, createdAt: Date().addingTimeInterval(-86400 * 60)),

        ConsultingListing(
            id: "co3", sellerId: "fik.shun",
            sellerUsername: "fik.shun", sellerDisplayName: "Fik-Shun",
            sellerImageURL: "https://i.pravatar.cc/200?img=8",
            sellerArtistType: .dancer,
            title: "Music Video & Commercial Dance Direction",
            tagline: "Street culture, cinematic eye, zero compromise.",
            specialties: ["Music Video", "Commercial", "Brand Campaign", "Festival"],
            scopeStatement: "I direct the movement and dancer casting for music videos and commercial productions. My specialty is street and animation styles integrated into high-production shoots. I do not direct non-dance-focused content.",
            dayRate: 2500, projectMinimum: 8000,
            retainerAvailable: false, retainerRateMonthly: nil,
            availabilityStatus: .open,
            bookedThrough: nil,
            pastProjects: [
                PastProject(id: "pp3a", name: "World of Dance Season 2",      artist: "NBC / JLo",         year: 2018, role: "Competitor & Guest"),
                PastProject(id: "pp3b", name: "Various Music Video Direction", artist: "Multiple Artists",  year: 2022, role: "Dance Director"),
                PastProject(id: "pp3c", name: "Nike x Street Dance Campaign",  artist: "Nike",              year: 2021, role: "Creative Consultant"),
            ],
            showreelURL: nil,
            portfolioURLs: ["https://picsum.photos/id/1062/600/400", "https://picsum.photos/id/349/600/400"],
            isActive: true, createdAt: Date().addingTimeInterval(-86400 * 30)),
    ]

    // MARK: - Show Creation Listings
    static let showListings: [ShowListing] = [
        ShowListing(
            id: "sh1", sellerId: "travispayne",
            sellerUsername: "travispayne", sellerDisplayName: "Travis Payne",
            sellerImageURL: "https://i.pravatar.cc/200?img=3",
            title: "The Rhythm Odyssey",
            description: "A full-scale concert narrative exploring the evolution of Black music from gospel to hip-hop, told entirely through dance, live vocals, and cinematic staging. Built for 5,000–20,000 seat arenas. Fully scripted, scored, and production-designed.",
            genreTags: ["Hip-Hop", "R&B", "Gospel", "Contemporary", "Narrative"],
            scale: .arena,
            moodBoardURLs: [
                "https://picsum.photos/id/1005/600/400",
                "https://picsum.photos/id/1014/600/400",
                "https://picsum.photos/id/338/600/400",
            ],
            tiersAvailable: [
                ShowTier(id: "st1a", tier: .conceptOnly,          price: 4500,  isNegotiated: false, exclusiveOptionAvailable: true,  exclusivePrice: 12000, territory: nil),
                ShowTier(id: "st1b", tier: .fullProductionRights, price: 45000, isNegotiated: false, exclusiveOptionAvailable: true,  exclusivePrice: nil,   territory: "Per Region"),
                ShowTier(id: "st1c", tier: .coCreation,           price: nil,   isNegotiated: true,  exclusiveOptionAvailable: false, exclusivePrice: nil,   territory: nil),
            ],
            activeConceptLicenses: 3,
            isActive: true, createdAt: Date().addingTimeInterval(-86400 * 30)),

        ShowListing(
            id: "sh2", sellerId: "laurieann.g",
            sellerUsername: "laurieann.g", sellerDisplayName: "Laurieann Gibson",
            sellerImageURL: "https://i.pravatar.cc/200?img=57",
            title: "Soul & Silhouette",
            description: "An intimate theatrical show framework built for 200–800 seat venues. Blending spoken word, live R&B performance, and contemporary dance, this concept creates a deeply personal audience experience. Designed for emerging artists building their first headline show.",
            genreTags: ["R&B", "Soul", "Spoken Word", "Contemporary", "Intimate Theater"],
            scale: .intimate,
            moodBoardURLs: [
                "https://picsum.photos/id/1074/600/400",
                "https://picsum.photos/id/1025/600/400",
            ],
            tiersAvailable: [
                ShowTier(id: "st2a", tier: .conceptOnly,          price: 2000,  isNegotiated: false, exclusiveOptionAvailable: false, exclusivePrice: nil,  territory: nil),
                ShowTier(id: "st2b", tier: .fullProductionRights, price: 15000, isNegotiated: false, exclusiveOptionAvailable: true,  exclusivePrice: nil,  territory: "Worldwide"),
                ShowTier(id: "st2c", tier: .coCreation,           price: nil,   isNegotiated: true,  exclusiveOptionAvailable: false, exclusivePrice: nil,  territory: nil),
            ],
            activeConceptLicenses: 7,
            isActive: true, createdAt: Date().addingTimeInterval(-86400 * 45)),

        ShowListing(
            id: "sh3", sellerId: "boogaloo.shrimp",
            sellerUsername: "boogaloo.shrimp", sellerDisplayName: "Boogaloo Shrimp",
            sellerImageURL: "https://i.pravatar.cc/200?img=15",
            title: "Concrete Canvas",
            description: "A mid-size hip-hop dance theater piece structured as a love letter to street culture. Five acts, each representing a decade of hip-hop — from the Bronx in 1973 to global culture today. Built for festivals, performing arts centers, and dance company residencies.",
            genreTags: ["Hip-Hop", "Breakdance", "Theater", "Street Culture", "Historical"],
            scale: .midSize,
            moodBoardURLs: [
                "https://picsum.photos/id/1012/600/400",
                "https://picsum.photos/id/342/600/400",
                "https://picsum.photos/id/355/600/400",
            ],
            tiersAvailable: [
                ShowTier(id: "st3a", tier: .conceptOnly,          price: 3000,  isNegotiated: false, exclusiveOptionAvailable: true,  exclusivePrice: 8500, territory: nil),
                ShowTier(id: "st3b", tier: .fullProductionRights, price: 28000, isNegotiated: false, exclusiveOptionAvailable: true,  exclusivePrice: nil,  territory: "Per Territory"),
                ShowTier(id: "st3c", tier: .coCreation,           price: nil,   isNegotiated: true,  exclusiveOptionAvailable: false, exclusivePrice: nil,  territory: nil),
            ],
            activeConceptLicenses: 2,
            isActive: true, createdAt: Date().addingTimeInterval(-86400 * 20)),
    ]
}
