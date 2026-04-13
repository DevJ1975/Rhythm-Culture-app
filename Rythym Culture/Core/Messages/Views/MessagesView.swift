// MessagesView.swift
// Direct messages — conversation list and thread view.

import SwiftUI

struct MessagesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private let conversations: [(user: AppUser, lastMessage: String, time: String, unread: Int)] = [
        (MockData.allUsers[1], "Got a beat that would go crazy over this 🎹", "2m", 3),
        (MockData.allUsers[2], "We need to work together ASAP. Seriously.", "14m", 1),
        (MockData.allUsers[3], "Respect from the OG 💯", "1h", 0),
        (MockData.allUsers[4], "Put me on the remix 🎧", "3h", 0),
        (MockData.allUsers[5], "Slide in the DMs for the collab", "5h", 0),
        (MockData.allUsers[6], "Fire content bro 🔥", "Yesterday", 0),
    ]

    var filtered: [(user: AppUser, lastMessage: String, time: String, unread: Int)] {
        guard !searchText.isEmpty else { return conversations }
        return conversations.filter {
            $0.user.username.localizedCaseInsensitiveContains(searchText) ||
            $0.user.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    EmptyStateView(icon: "bubble.left.and.bubble.right",
                                   title: "No conversations",
                                   subtitle: "Start a conversation by visiting someone's profile.")
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filtered, id: \.user.id) { item in
                            NavigationLink(destination: MessageThreadView(user: item.user)) {
                                ConversationRow(user: item.user, lastMessage: item.lastMessage,
                                                time: item.time, unreadCount: item.unread)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $searchText, prompt: "Search messages")
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").foregroundStyle(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Image(systemName: "square.and.pencil").foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - Conversation Row
private struct ConversationRow: View {
    let user: AppUser
    let lastMessage: String
    let time: String
    let unreadCount: Int

    var body: some View {
        HStack(spacing: 12) {
            RemoteImage(url: user.profileImageURL ?? MockData.avatarURL(user.id))
                .frame(width: 52, height: 52)
                .clipShape(Circle())
                .overlay(Circle().stroke(user.artistType?.color ?? .gray, lineWidth: 1.5))

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(user.displayName)
                        .font(unreadCount > 0 ? .subheadline.bold() : .subheadline)
                    Spacer()
                    Text(time).font(.caption).foregroundStyle(.secondary)
                }
                HStack {
                    Text(lastMessage)
                        .font(.caption)
                        .foregroundStyle(unreadCount > 0 ? .primary : .secondary)
                        .lineLimit(1)
                    Spacer()
                    if unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(5)
                            .background(.purple)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Message Thread View
struct MessageThreadView: View {
    let user: AppUser
    @State private var messageText = ""
    @FocusState private var inputFocused: Bool

    private let mockMessages: [(text: String, isMe: Bool, time: String)] = [
        ("Fire content bro 🔥", false, "3h"),
        ("Appreciate it! Been working hard on this one.", true, "3h"),
        ("Got a beat that would go crazy over this energy. Slide in the DMs 🎹", false, "2h"),
        ("Say less — send it over!", true, "2h"),
        ("Just sent. Let me know what you think 🎧", false, "1h"),
        ("This is hard!! We need to link up for real.", true, "45m"),
        ("100%. Let's make it happen 🤝", false, "30m"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(mockMessages.indices, id: \.self) { i in
                        let msg = mockMessages[i]
                        MessageBubble(text: msg.text, isMe: msg.isMe, time: msg.time)
                    }
                }
                .padding(12)
            }

            Divider()

            HStack(spacing: 10) {
                TextField("Message...", text: $messageText)
                    .font(.subheadline)
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                    .focused($inputFocused)

                Button {
                    messageText = ""
                } label: {
                    Image(systemName: messageText.isEmpty ? "mic.fill" : "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(messageText.isEmpty ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.purple))
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    RemoteImage(url: user.profileImageURL ?? MockData.avatarURL(user.id))
                        .frame(width: 32, height: 32).clipShape(Circle())
                    VStack(alignment: .leading, spacing: 0) {
                        Text(user.displayName).font(.subheadline.bold())
                        if let type = user.artistType {
                            Text(type.rawValue).font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}

private struct MessageBubble: View {
    let text: String
    let isMe: Bool
    let time: String

    var body: some View {
        HStack {
            if isMe { Spacer(minLength: 60) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: 3) {
                Text(text)
                    .font(.subheadline)
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .background(isMe
                        ? AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        : AnyShapeStyle(Color(.systemGray5)))
                    .foregroundStyle(isMe ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                Text(time).font(.caption2).foregroundStyle(.secondary).padding(.horizontal, 4)
            }
            if !isMe { Spacer(minLength: 60) }
        }
    }
}
