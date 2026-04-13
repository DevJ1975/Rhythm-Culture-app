// FeedView.swift
// Home feed — Stories, active Spaces strip, and post stream.

import SwiftUI

struct FeedView: View {
    @State private var posts = MockData.posts
    @State private var showCreatePost = false
    @State private var showMessages = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    Divider()

                    StoriesRowView(stories: MockData.stories)
                    Divider()

                    SpacesStripView(spaces: MockData.spaces)
                    Divider()

                    ForEach(posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostCellView(post: post)
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                }
            }
            .refreshable {
                try? await Task.sleep(nanoseconds: 800_000_000)
                posts = MockData.posts
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
            .sheet(isPresented: $showCreatePost) { CreatePostView() }
            .sheet(isPresented: $showMessages) { MessagesView() }
            .navigationDestination(for: AppUser.self) { user in
                ProfileView(user: user)
            }
        }
    }
}
