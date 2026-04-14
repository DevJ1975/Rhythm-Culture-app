// NotificationsView.swift
// Activity feed — likes, comments, follows, battle votes, collab applications.

import SwiftUI

struct NotificationsView: View {
    @State private var notifications = MockData.notifications
    @State private var isRefreshing = false

    private var newNotifs: [MockData.MockNotification] { notifications.filter { !$0.isRead } }
    private var earlierNotifs: [MockData.MockNotification] { notifications.filter { $0.isRead } }

    var body: some View {
        NavigationStack {
            Group {
                if notifications.isEmpty {
                    EmptyStateView(
                        icon: "bell.slash",
                        title: "No activity yet",
                        subtitle: "When people like, comment, or follow you, it'll show up here."
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        if !newNotifs.isEmpty {
                            Section("New") {
                                ForEach(newNotifs) { notif in
                                    NotificationRow(notif: notif)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                                }
                            }
                        }
                        if !earlierNotifs.isEmpty {
                            Section("Earlier") {
                                ForEach(earlierNotifs) { notif in
                                    NotificationRow(notif: notif)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { try? await Task.sleep(nanoseconds: 800_000_000) }
                }
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !newNotifs.isEmpty {
                        Button("Mark all read") {
                            withAnimation {
                                notifications = notifications.map {
                                    MockData.MockNotification(
                                        id: $0.id, type: $0.type,
                                        actorUsername: $0.actorUsername, actorImageURL: $0.actorImageURL,
                                        message: $0.message, thumbnailURL: $0.thumbnailURL,
                                        isRead: true, createdAt: $0.createdAt)
                                }
                            }
                        }
                        .font(.caption.bold())
                    }
                }
            }
        }
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let notif: MockData.MockNotification
    @State private var isFollowing = false

    var body: some View {
        HStack(spacing: 12) {
            // Unread dot
            Circle()
                .fill(notif.isRead ? Color.clear : Color.purple)
                .frame(width: 8, height: 8)

            // Actor avatar
            ZStack(alignment: .bottomTrailing) {
                RemoteImage(url: notif.actorImageURL)
                    .frame(width: 46, height: 46)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.systemGray5), lineWidth: 1))

                // Type icon badge
                Circle()
                    .fill(typeColor)
                    .frame(width: 18, height: 18)
                    .overlay(Image(systemName: typeIcon).font(.system(size: 9, weight: .bold)).foregroundStyle(.white))
                    .offset(x: 4, y: 4)
            }

            // Message text
            VStack(alignment: .leading, spacing: 3) {
                attributedMessage
                    .font(.subheadline)
                    .lineLimit(2)
                Text(notif.createdAt.timeAgoDisplay())
                    .font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            // Right side: thumbnail or follow button
            if let thumb = notif.thumbnailURL {
                RemoteImage(url: thumb)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else if notif.type == .follow {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isFollowing.toggle() }
                } label: {
                    Text(isFollowing ? "Following" : "Follow")
                        .font(.caption.bold())
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(isFollowing
                            ? AnyShapeStyle(Color(.systemGray5))
                            : AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)))
                        .foregroundStyle(isFollowing ? AnyShapeStyle(.primary) : AnyShapeStyle(Color.white))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
        .opacity(notif.isRead ? 0.75 : 1.0)
    }

    private var attributedMessage: Text {
        // Bold the actor username
        let parts = notif.message.split(separator: " ", maxSplits: 1)
        guard parts.count == 2 else { return Text(notif.message) }
        return Text("\(Text(String(parts[0])).fontWeight(.semibold)) \(String(parts[1]))")
    }

    private var typeIcon: String {
        switch notif.type {
        case .like:        return "heart.fill"
        case .comment:     return "bubble.right.fill"
        case .follow:      return "person.fill"
        case .battleVote:  return "trophy.fill"
        case .collabApply: return "person.2.fill"
        case .spaceInvite: return "mic.fill"
        }
    }

    private var typeColor: Color {
        switch notif.type {
        case .like:        return .red
        case .comment:     return .purple
        case .follow:      return .blue
        case .battleVote:  return .orange
        case .collabApply: return .teal
        case .spaceInvite: return .green
        }
    }
}
