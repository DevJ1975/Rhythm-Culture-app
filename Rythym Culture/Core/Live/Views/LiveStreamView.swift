// LiveStreamView.swift
// Full-screen live stream viewer + GoLive host setup.

import SwiftUI

// MARK: - Live Stream Viewer
struct LiveStreamView: View {
    let stream: LiveStream
    @Environment(\.dismiss) private var dismiss
    @State private var commentText = ""
    @State private var showGiftSheet = false

    private let mockComments: [(username: String, text: String)] = [
        ("j.jones",       "Let's gooo!! 🔥🔥"),
        ("culture.hq",    "This is insane"),
        ("vibez_media",   "Top tier content always 💯"),
        ("artby.kash",    "Came here from your story ❤️"),
        ("musik.lover",   "Someone clip this right now"),
        ("fik.shun",      "Legendary 🐐"),
        ("boogaloo",      "The GOAT is live!"),
        ("wave.rider",    "First time catching a live 🙌"),
        ("thereal_rc",    "This is what RC is for"),
        ("dj.jazzy.jeff", "Mad respect bro"),
    ]

    var body: some View {
        ZStack {
            // Background — would be live video feed in production
            RemoteImage(url: stream.hostImageURL, contentMode: .fill)
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.45))

            VStack {
                // Top bar
                HStack {
                    HStack(spacing: 8) {
                        RemoteImage(url: stream.hostImageURL)
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))

                        VStack(alignment: .leading, spacing: 1) {
                            Text(stream.hostDisplayName)
                                .font(.subheadline.bold()).foregroundStyle(.white)
                            HStack(spacing: 4) {
                                Text("LIVE")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 5).padding(.vertical, 2)
                                    .background(.red).clipShape(Capsule())
                                Text(stream.viewerCount.shortFormatted() + " watching")
                                    .font(.caption).foregroundStyle(.white.opacity(0.8))
                            }
                        }
                    }

                    Spacer()

                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.title3.bold()).foregroundStyle(.white)
                            .padding(10)
                            .background(.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Stream title
                Text(stream.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                // Comments stream
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(mockComments.suffix(6), id: \.username) { comment in
                        HStack(spacing: 8) {
                            Text(comment.username)
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                            Text(comment.text)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(.black.opacity(0.35))
                        .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

                // Bottom input
                HStack(spacing: 12) {
                    TextField("Say something...", text: $commentText)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(.black.opacity(0.4))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())

                    Button { showGiftSheet = true } label: {
                        Image(systemName: "gift.fill")
                            .font(.title3).foregroundStyle(.yellow)
                            .padding(12)
                            .background(.black.opacity(0.4))
                            .clipShape(Circle())
                    }

                    Button {} label: {
                        Image(systemName: "heart.fill")
                            .font(.title3).foregroundStyle(.red)
                            .padding(12)
                            .background(.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $showGiftSheet) {
            GiftPickerView()
                .presentationDetents([.height(300)])
        }
    }
}

// MARK: - Gift Picker
struct GiftPickerView: View {
    @Environment(\.dismiss) private var dismiss

    private let gifts: [(emoji: String, name: String, coins: Int)] = [
        ("🌹", "Rose",      10),
        ("🔥", "Fire",      50),
        ("💎", "Diamond",   200),
        ("🏆", "Trophy",    500),
        ("🚀", "Rocket",    1000),
        ("👑", "Crown",     2000),
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Send a Gift")
                .font(.headline)
                .padding(.top, 16)
            Text("RC keeps 30% · Artist receives 70%")
                .font(.caption).foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(gifts, id: \.name) { gift in
                    Button {
                        dismiss()
                    } label: {
                        VStack(spacing: 6) {
                            Text(gift.emoji).font(.system(size: 36))
                            Text(gift.name).font(.caption.bold())
                            HStack(spacing: 3) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.caption2).foregroundStyle(.yellow)
                                Text("\(gift.coins)").font(.caption2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Go Live Setup
struct GoLiveView: View {
    let user: AppUser
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var isLive = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Camera preview placeholder
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .frame(height: 300)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 48)).foregroundStyle(.secondary)
                            Text("Camera Preview").foregroundStyle(.secondary)
                        }
                    )
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Stream Title").font(.subheadline.bold())
                    TextField("What are you streaming today?", text: $title)
                        .padding(14)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)

                // Tip about gifts
                HStack(spacing: 10) {
                    Image(systemName: "gift.fill").foregroundStyle(.yellow)
                    Text("Viewers can send gifts during your live. You earn 70% of all gifts received.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color.yellow.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)

                Spacer()

                Button {
                    guard !title.isEmpty else { return }
                    isLive = true
                } label: {
                    HStack {
                        Image(systemName: "record.circle")
                        Text("Go Live")
                    }
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity).padding()
                    .background(title.isEmpty ? Color(.systemGray4) : Color.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(title.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Go Live")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $isLive) {
                LiveStreamView(stream: LiveStream(
                    id: UUID().uuidString,
                    hostId: user.id,
                    hostUsername: user.username,
                    hostDisplayName: user.displayName,
                    hostImageURL: user.profileImageURL ?? MockData.avatarURL(user.id),
                    title: title,
                    viewerCount: 0,
                    isActive: true,
                    startedAt: .now
                ))
            }
        }
    }
}
