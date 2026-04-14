// StoriesRowView.swift
// Horizontal scrollable story bubbles shown at the top of the feed.

import SwiftUI

struct StoriesRowView: View {
    let stories: [StoryItem]
    @State private var selectedStory: StoryItem?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(stories) { story in
                    StoryBubbleView(story: story)
                        .onTapGesture { selectedStory = story }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .fullScreenCover(item: $selectedStory) { story in
            let startIndex = stories.firstIndex(where: { $0.id == story.id }) ?? 0
            StoryViewerView(stories: stories, startIndex: startIndex)
        }
    }
}

struct StoryBubbleView: View {
    let story: StoryItem

    var body: some View {
        VStack(spacing: 6) {
                ZStack {
                    // Gradient ring for unseen stories
                    if story.hasUnseenStory {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.purple, .pink, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                            .frame(width: 70, height: 70)
                    }

                    // Avatar photo or gradient fallback
                    Circle()
                        .frame(width: 62, height: 62)
                        .overlay(
                            Group {
                                if let url = story.imageURL {
                                    RemoteImage(url: url)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: story.gradientColors,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            Text(story.username.prefix(1).uppercased())
                                                .font(.title3.bold())
                                                .foregroundStyle(.white)
                                        )
                                }
                            }
                        )
                        .clipShape(Circle())

                    // Self add indicator
                    if story.isSelf {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 22, height: 22)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                            .offset(x: 20, y: 20)
                    }
                }

                Text(story.isSelf ? "Your story" : story.username)
                    .font(.caption2)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .frame(width: 70)
        }
    }
}
