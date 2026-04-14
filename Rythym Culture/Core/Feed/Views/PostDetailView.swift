// PostDetailView.swift
// Full post view with comments thread and comment input.

import SwiftUI

struct PostDetailView: View {
    let post: Post
    @State private var comments: [Comment] = []
    @State private var commentText = ""
    @State private var isLiked: Bool
    @State private var likesCount: Int
    @State private var isBookmarked = false
    @State private var showPostMenu = false
    @State private var showReportAlert = false
    @FocusState private var inputFocused: Bool

    init(post: Post) {
        self.post = post
        _isLiked = State(initialValue: post.isLikedByCurrentUser)
        _likesCount = State(initialValue: post.likesCount)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Post header
                postHeader

                // Post image
                if let urlString = post.mediaURLs.first {
                    RemoteImage(url: urlString)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                }

                // Action bar
                HStack(spacing: 16) {
                    Button { toggleLike() } label: {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(isLiked ? .red : .primary)
                            .symbolEffect(.bounce, value: isLiked)
                    }
                    Button { inputFocused = true } label: {
                        Image(systemName: "bubble.right").font(.title2).foregroundStyle(.primary)
                    }
                    ShareLink(item: URL(string: "https://rhythmculture.app/p/\(post.id)")!,
                              subject: Text(post.authorUsername),
                              message: Text(post.caption)) {
                        Image(systemName: "paperplane").font(.title2).foregroundStyle(.primary)
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isBookmarked.toggle() }
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.title2).foregroundStyle(.primary)
                            .symbolEffect(.bounce, value: isBookmarked)
                    }
                }
                .padding(.horizontal, 14).padding(.top, 12)

                // Likes + caption
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(likesCount.shortFormatted()) likes").font(.subheadline.bold())
                    Text("\(Text(post.authorUsername).fontWeight(.semibold)) \(post.caption)")
                        .font(.subheadline)
                    Text(post.createdAt.timeAgoDisplay()).font(.caption).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14).padding(.top, 8).padding(.bottom, 16)

                Divider()

                // Comments section
                if comments.isEmpty {
                    Text("No comments yet. Be the first.")
                        .font(.subheadline).foregroundStyle(.secondary)
                        .padding(20)
                } else {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(comments) { comment in
                            CommentRow(comment: comment)
                            Divider().padding(.leading, 66)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Comments")
        .safeAreaInset(edge: .bottom) {
            commentInputBar
        }
        .onAppear {
            comments = MockData.comments(for: post.id)
        }
    }

    // MARK: - Post Header
    private var postHeader: some View {
        HStack(spacing: 10) {
            NavigationLink(destination: ProfileView(user: MockData.user(forId: post.authorId) ?? MockData.currentUser)) {
                RemoteImage(url: MockData.avatarURL(post.authorId))
                    .frame(width: 36, height: 36).clipShape(Circle())
            }
            .buttonStyle(.plain)

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
            Button { showPostMenu = true } label: {
                Image(systemName: "ellipsis").foregroundStyle(.primary).padding(8)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .confirmationDialog("Post Options", isPresented: $showPostMenu) {
            Button("Copy Link") {
                UIPasteboard.general.string = "https://rhythmculture.app/p/\(post.id)"
            }
            Button("Not Interested") {}
            Button("Report", role: .destructive) { showReportAlert = true }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Thanks for your report", isPresented: $showReportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We'll review this post and take appropriate action.")
        }
    }

    // MARK: - Comment Input Bar
    private var commentInputBar: some View {
        HStack(spacing: 10) {
            RemoteImage(url: MockData.currentUser.profileImageURL ?? "")
                .frame(width: 32, height: 32).clipShape(Circle())

            HStack {
                TextField("Add a comment...", text: $commentText)
                    .font(.subheadline)
                    .focused($inputFocused)

                if !commentText.isEmpty {
                    Button("Post") {
                        submitComment()
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.purple)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    // MARK: - Helpers
    private func toggleLike() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isLiked.toggle()
            likesCount += isLiked ? 1 : -1
        }
    }

    private func submitComment() {
        let newComment = Comment(
            id: UUID().uuidString,
            authorId: MockData.currentUser.id,
            authorUsername: MockData.currentUser.username,
            authorImageURL: MockData.currentUser.profileImageURL ?? "",
            text: commentText,
            likesCount: 0,
            isLikedByCurrentUser: false,
            createdAt: .now
        )
        withAnimation { comments.insert(newComment, at: 0) }
        commentText = ""
        inputFocused = false
    }
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: Comment
    @State private var isLiked: Bool
    @State private var likesCount: Int

    init(comment: Comment) {
        self.comment = comment
        _isLiked = State(initialValue: comment.isLikedByCurrentUser)
        _likesCount = State(initialValue: comment.likesCount)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            NavigationLink(destination: ProfileView(user: MockData.user(forId: comment.authorId) ?? MockData.currentUser)) {
                RemoteImage(url: comment.authorImageURL)
                    .frame(width: 34, height: 34).clipShape(Circle())
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(Text(comment.authorUsername).fontWeight(.semibold)) \(comment.text)")
                    .font(.subheadline)
                HStack(spacing: 12) {
                    Text(comment.createdAt.timeAgoDisplay())
                        .font(.caption).foregroundStyle(.secondary)
                    if likesCount > 0 {
                        Text("\(likesCount.shortFormatted()) likes")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Button("Reply") {}
                        .font(.caption.bold()).foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button { withAnimation { isLiked.toggle(); likesCount += isLiked ? 1 : -1 } } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.caption)
                    .foregroundStyle(isLiked ? .red : .secondary)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
    }
}
