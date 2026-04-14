// FeedView.swift
// Home feed — Stories, active Spaces strip, feed mode picker, ranked posts, and injected ads.

import SwiftUI

// Unified feed item type — organic post or sponsored ad.
enum FeedItem: Identifiable {
    case post(Post)
    case ad(AdPost)

    var id: String {
        switch self {
        case .post(let p): return "post_\(p.id)"
        case .ad(let a):   return "ad_\(a.id)"
        }
    }
}

struct FeedView: View {
    @State private var posts = MockData.posts
    @State private var feedMode: FeedMode = .trending
    @State private var showCreatePost = false
    @State private var showMessages = false
    @State private var cachedFeedItems: [FeedItem] = []

    private func rebuildFeed() {
        let ranked = FeedRanker.rank(posts, mode: feedMode)
        var items: [FeedItem] = []
        for (index, post) in ranked.enumerated() {
            items.append(.post(post))
            if let ad = MockData.ad(afterIndex: index) {
                items.append(.ad(ad))
            }
        }
        cachedFeedItems = items
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    Divider()

                    StoriesRowView(stories: MockData.stories)
                    Divider()

                    SpacesStripView(spaces: MockData.spaces)
                    Divider()

                    feedModePicker
                    Divider()

                    ForEach(cachedFeedItems) { item in
                        switch item {
                        case .post(let post):
                            NavigationLink(destination: PostDetailView(post: post)) {
                                PostCellView(post: post)
                            }
                            .buttonStyle(.plain)
                        case .ad(let ad):
                            AdPostCellView(ad: ad)
                        }
                        Divider()
                    }
                }
            }
            .onAppear { if cachedFeedItems.isEmpty { rebuildFeed() } }
            .onChange(of: posts.count) { rebuildFeed() }
            .onChange(of: feedMode) { withAnimation { rebuildFeed() } }
            .refreshable {
                try? await Task.sleep(nanoseconds: 800_000_000)
                // Merge refreshed mock posts without dropping user-created posts
                let existingIds = Set(posts.map { $0.id })
                let newMockPosts = MockData.posts.filter { !existingIds.contains($0.id) }
                posts = posts + newMockPosts
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showCreatePost = true } label: {
                        Image(systemName: "plus.app").foregroundStyle(.primary)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Rhythm Culture")
                        .font(.system(size: 22, weight: .bold, design: .default))
                        .foregroundStyle(.purple)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showMessages = true } label: {
                        Image(systemName: "paperplane").foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView { newPost in
                    posts.insert(newPost, at: 0)
                    feedMode = .following   // switch to chronological so new post is at top
                    // onChange(of: posts) will rebuild the cache automatically
                }
            }
            .sheet(isPresented: $showMessages) { MessagesView() }
            .navigationDestination(for: AppUser.self) { user in
                ProfileView(user: user)
            }
        }
    }

    // MARK: - Feed Mode Picker
    private var feedModePicker: some View {
        HStack(spacing: 0) {
            ForEach(FeedMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        feedMode = mode
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: mode.icon)
                            .font(.caption.bold())
                        Text(mode.rawValue)
                            .font(.subheadline.bold())
                    }
                    .foregroundStyle(feedMode == mode ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(
                        feedMode == mode
                            ? AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(Color.clear)
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}
