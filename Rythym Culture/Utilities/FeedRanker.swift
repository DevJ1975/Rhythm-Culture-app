// FeedRanker.swift
// Feed ranking algorithm — viral score with recency decay.

import Foundation

enum FeedMode: String, CaseIterable, Identifiable {
    case trending  = "Trending"
    case following = "Following"
    case fresh     = "Fresh"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .trending:  return "flame.fill"
        case .following: return "person.2.fill"
        case .fresh:     return "sparkles"
        }
    }
}

enum FeedRanker {

    // Viral score: weighted engagement divided by recency decay.
    // Weights: likes ×1, comments ×3 (high intent), vibes ×2, recency decay ^1.3
    static func viralScore(for post: Post) -> Double {
        let hoursOld = max(1, -post.createdAt.timeIntervalSinceNow / 3600)
        let engagement = Double(post.likesCount) * 1.0
                       + Double(post.commentsCount) * 3.0
                       + Double(post.vibeReactions.total) * 2.0
        return engagement / pow(hoursOld, 1.3)
    }

    static func rank(_ posts: [Post], mode: FeedMode) -> [Post] {
        switch mode {
        case .trending:
            return posts.sorted { viralScore(for: $0) > viralScore(for: $1) }

        case .following:
            // Chronological — most recent first
            return posts.sorted { $0.createdAt > $1.createdAt }

        case .fresh:
            // Only posts under 24 hours old, sorted by viral score
            let cutoff = Date().addingTimeInterval(-86400)
            return posts
                .filter { $0.createdAt > cutoff }
                .sorted { viralScore(for: $0) > viralScore(for: $1) }
        }
    }
}
