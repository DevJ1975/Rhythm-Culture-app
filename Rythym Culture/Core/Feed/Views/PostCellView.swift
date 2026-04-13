// PostCellView.swift
// Instagram-style post card with artist badges, post-type banners, and vibe reactions.

import SwiftUI

struct PostCellView: View {
    let post: Post

    @State private var isLiked: Bool
    @State private var likesCount: Int
    @State private var isBookmarked = false
    @State private var showHeartAnimation = false
    @State private var myVibe: VibeType? = nil
    @State private var showVibeBar = false
    @State private var vibeReactions: Post.VibeReactions

    enum VibeType: String, CaseIterable {
        case fire    = "🔥"
        case move    = "💃"
        case vibes   = "🎵"
        case respect = "👏"

        var label: String {
            switch self {
            case .fire:    return "Fire"
            case .move:    return "Move"
            case .vibes:   return "Vibes"
            case .respect: return "Respect"
            }
        }

        var count: (Post.VibeReactions) -> Int {
            switch self {
            case .fire:    return { $0.fire }
            case .move:    return { $0.move }
            case .vibes:   return { $0.vibes }
            case .respect: return { $0.respect }
            }
        }
    }

    private static let gradients: [[Color]] = [
        [.purple, .pink], [.blue, .cyan], [.orange, .red],
        [.green, .teal], [.indigo, .blue], [.pink, .orange],
    ]
    private var avatarGradient: [Color] {
        Self.gradients[abs(post.authorId.hashValue) % Self.gradients.count]
    }

    init(post: Post) {
        self.post = post
        _isLiked = State(initialValue: post.isLikedByCurrentUser)
        _likesCount = State(initialValue: post.likesCount)
        _vibeReactions = State(initialValue: post.vibeReactions)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if post.postType != .standard { postTypeBanner }
            postHeader
            postMedia
            actionBar
            if showVibeBar { vibeReactionBar.transition(.move(edge: .bottom).combined(with: .opacity)) }
            vibeReactionSummary
            postMeta
        }
    }

    // MARK: – Post Type Banner
    private var postTypeBanner: some View {
        let config = bannerConfig(for: post.postType)
        return HStack(spacing: 6) {
            Text(config.emoji)
            Text(config.label.uppercased())
                .font(.caption.bold())
                .tracking(1)
            Spacer()
            if let genre = post.genre {
                Text(genre).font(.caption2.bold()).opacity(0.8)
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(LinearGradient(colors: config.gradient, startPoint: .leading, endPoint: .trailing))
    }

    private func bannerConfig(for type: Post.PostType) -> (emoji: String, label: String, gradient: [Color]) {
        switch type {
        case .drop:     return ("🎵", "New Drop",       [.purple, .blue])
        case .battle:   return ("⚔️", "Battle Entry",   [.red, .orange])
        case .showcase: return ("⭐", "Showcase",        [.orange, .yellow])
        case .collab:   return ("🤝", "Collab Request", [.blue, .teal])
        case .standard: return ("",   "",               [])
        }
    }

    // MARK: – Header
    private var postHeader: some View {
        HStack(spacing: 10) {
            // Avatar
            Circle()
                .frame(width: 36, height: 36)
                .overlay(
                    RemoteImage(url: MockData.avatarURL(post.authorId))
                        .clipShape(Circle())
                )
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(post.authorUsername).font(.subheadline.bold())
                    if let type = post.authorArtistType {
                        ArtistBadgeView(artistType: type, compact: true)
                    }
                    if let tier = MockData.sellerTier(forUserId: post.authorId) {
                        SellerTierBadgeView(tier: tier, compact: true)
                    }
                }
                if let genre = post.genre {
                    Text(genre).font(.caption2).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button { } label: {
                Image(systemName: "ellipsis").foregroundStyle(.primary).padding(8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    // MARK: – Media
    private var postMedia: some View {
        ZStack {
            if let urlString = post.mediaURLs.first {
                RemoteImage(url: urlString)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
            } else {
                Rectangle()
                    .fill(LinearGradient(colors: avatarGradient.map { $0.opacity(0.35) },
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(Image(systemName: "photo").font(.system(size: 52)).foregroundStyle(.white.opacity(0.3)))
            }

            if showHeartAnimation {
                Image(systemName: "heart.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(.white)
                    .shadow(radius: 10)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onTapGesture(count: 2) { handleDoubleTapLike() }
    }

    // MARK: – Action Bar
    private var actionBar: some View {
        HStack(spacing: 16) {
            Button { toggleLike() } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundStyle(isLiked ? .red : .primary)
                    .symbolEffect(.bounce, value: isLiked)
            }
            Button { } label: {
                Image(systemName: "bubble.right").font(.title2).foregroundStyle(.primary)
            }
            Button { } label: {
                Image(systemName: "paperplane").font(.title2).foregroundStyle(.primary)
            }
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showVibeBar.toggle() }
            } label: {
                HStack(spacing: 3) {
                    Text(myVibe?.rawValue ?? "✨").font(.title3)
                    Text("Vibe").font(.caption.bold()).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isBookmarked.toggle() }
            } label: {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.title2).foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
    }

    // MARK: – Vibe Bar
    private var vibeReactionBar: some View {
        HStack(spacing: 0) {
            ForEach(VibeType.allCases, id: \.self) { vibe in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        myVibe = myVibe == vibe ? nil : vibe
                        showVibeBar = false
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(vibe.rawValue).font(.title2).scaleEffect(myVibe == vibe ? 1.3 : 1.0)
                        Text(vibe.label).font(.caption2).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(myVibe == vibe ? Color(.systemGray5) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .background(Color(.systemGray6))
    }

    // MARK: – Vibe Summary
    private var vibeReactionSummary: some View {
        Group {
            if vibeReactions.total > 0 {
                HStack(spacing: 10) {
                    ForEach(VibeType.allCases, id: \.self) { vibe in
                        let count = vibe.count(vibeReactions)
                        if count > 0 {
                            HStack(spacing: 3) {
                                Text(vibe.rawValue).font(.caption)
                                Text(count.shortFormatted()).font(.caption.bold()).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
            }
        }
    }

    // MARK: – Post Meta
    private var postMeta: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(likesCount.shortFormatted()) likes").font(.subheadline.bold())
            (Text(post.authorUsername).fontWeight(.semibold) + Text(" ") + Text(post.caption))
                .font(.subheadline).lineLimit(3)
            if post.commentsCount > 0 {
                Button { } label: {
                    Text("View all \(post.commentsCount) comments").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Text(post.createdAt.timeAgoDisplay()).font(.caption).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }

    // MARK: – Helpers
    private func toggleLike() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isLiked.toggle()
            likesCount += isLiked ? 1 : -1
        }
    }

    private func handleDoubleTapLike() {
        if !isLiked {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isLiked = true; likesCount += 1
            }
        }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { showHeartAnimation = true }
        Task {
            try? await Task.sleep(for: .seconds(0.9))
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.3)) { showHeartAnimation = false }
            }
        }
    }
}
