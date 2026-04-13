// SpacesStripView.swift
// Horizontal listening strip in the Home feed + full room view.

import SwiftUI

struct SpacesStripView: View {
    let spaces: [Space]
    @State private var selectedSpace: Space?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(.red).frame(width: 8, height: 8)
                    Text("Live Spaces")
                        .font(.subheadline.bold())
                }
                Spacer()
                Button("See All") {}
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(spaces) { space in
                        SpaceCardView(space: space)
                            .onTapGesture { selectedSpace = space }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .background(Color(.systemGray6).opacity(0.5))
        .sheet(item: $selectedSpace) { SpaceRoomView(space: $0) }
    }
}

struct SpaceCardView: View {
    let space: Space

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                RemoteImage(url: MockData.avatarURL(space.hostUsername))
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))

                Text("LIVE")
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4).padding(.vertical, 2)
                    .background(.red)
                    .clipShape(Capsule())
                    .offset(x: 4, y: 4)
            }

            Text(space.title)
                .font(.caption.bold())
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)

            if !space.speakerUsernames.isEmpty {
                HStack(spacing: -6) {
                    ForEach(space.speakerUsernames.prefix(3), id: \.self) { u in
                        RemoteImage(url: MockData.avatarURL(u))
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 1.5))
                    }
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "headphones").font(.caption2)
                Text(space.listenerCount.shortFormatted()).font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 164)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}

struct SpaceRoomView: View {
    let space: Space
    @Environment(\.dismiss) private var dismiss
    @State private var isMicRequested = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let topic = space.topic {
                        Text(topic)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                    }

                    VStack(spacing: 16) {
                        Text("Host & Speakers")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            speakerBubble(username: space.hostUsername, isHost: true)
                            ForEach(space.speakerUsernames, id: \.self) {
                                speakerBubble(username: $0, isHost: false)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Divider().padding(.horizontal, 20)

                    HStack {
                        Image(systemName: "person.2.fill").foregroundStyle(.secondary)
                        Text("\(space.listenerCount.shortFormatted()) listening")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 100)
                }
            }
            .navigationTitle(space.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Leave") { dismiss() }.foregroundStyle(.red)
                }
            }
            .safeAreaInset(edge: .bottom) { roomControls }
        }
    }

    private func speakerBubble(username: String, isHost: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                RemoteImage(url: MockData.avatarURL(username))
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(isHost ? Color.purple : Color(.systemGray4), lineWidth: isHost ? 2.5 : 1.5))

                if isHost {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 10)).foregroundStyle(.white)
                        .padding(4).background(Color.purple)
                        .clipShape(Circle()).offset(x: 4, y: 4)
                }
            }
            Text(username).font(.caption).lineLimit(1)
            if isHost { Text("Host").font(.caption2).foregroundStyle(.purple) }
        }
    }

    private var roomControls: some View {
        HStack(spacing: 32) {
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isMicRequested.toggle() }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: isMicRequested ? "hand.raised.fill" : "hand.raised").font(.title2)
                    Text(isMicRequested ? "Requested" : "Request Mic").font(.caption2)
                }
                .foregroundStyle(isMicRequested ? .purple : .primary)
            }
            Button {} label: {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up").font(.title2)
                    Text("Share").font(.caption2)
                }
                .foregroundStyle(.primary)
            }
            Spacer()
        }
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }
}
