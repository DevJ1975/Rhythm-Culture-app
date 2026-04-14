// ProfileView.swift
// Artist profile with Go Live, post grid, and artist identity.

import SwiftUI

struct ProfileView: View {
    let user: AppUser
    @State private var selectedGridTab = 0
    @State private var showGoLive = false
    @State private var showLiveStream: LiveStream? = nil
    @State private var showSettings = false

    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showEditProfile = false

    private let columns = [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]

    init(user: AppUser = MockData.currentUser) {
        self.user = user
    }

    // Use live authViewModel data when this is the current user's own profile
    private var displayUser: AppUser {
        guard let live = authViewModel.currentUser, live.id == user.id else { return user }
        return live
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    profileHeader
                    Divider()
                    gridTabs
                    postGrid
                }
            }
            .navigationTitle(displayUser.username)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "line.3.horizontal").foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(user: authViewModel.currentUser ?? user)
            }
            .sheet(isPresented: $showGoLive) {
                GoLiveView(user: authViewModel.currentUser ?? user)
            }
            .sheet(item: $showLiveStream) { LiveStreamView(stream: $0) }
            .sheet(isPresented: $showSettings) {
                SettingsSheet(isDarkMode: $isDarkMode) {
                    showSettings = false
                    Task { await authViewModel.signOut() }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                // Avatar with optional LIVE badge
                ZStack(alignment: .bottomTrailing) {
                    avatarView
                    if MockData.liveStreams.contains(where: { $0.hostId == displayUser.id && $0.isActive }) {
                        Text("LIVE")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(.red)
                            .clipShape(Capsule())
                            .offset(y: 6)
                    }
                }

                // Stats
                HStack(spacing: 0) {
                    statColumn(value: displayUser.postsCount, label: "Posts")
                    statColumn(value: displayUser.followersCount, label: "Followers")
                    statColumn(value: displayUser.followingCount, label: "Following")
                }
            }

            // Name, Artist Badge & Seller Tier
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayUser.displayName).font(.subheadline.bold())
                    HStack(spacing: 6) {
                        if let type = displayUser.artistType {
                            ArtistBadgeView(artistType: type)
                        }
                        if let tier = MockData.sellerTier(forUserId: displayUser.id) {
                            SellerTierBadgeView(tier: tier)
                        }
                    }
                }
                Spacer()
            }

            // Bio
            if let bio = displayUser.bio {
                Text(bio).font(.subheadline)
            }

            // Location & genres
            if let location = displayUser.location {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle").font(.caption).foregroundStyle(.secondary)
                    Text(location).font(.caption).foregroundStyle(.secondary)
                }
            }
            if !displayUser.genres.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(displayUser.genres, id: \.self) { genre in
                            Text(genre)
                                .font(.caption)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // Action buttons
            HStack(spacing: 8) {
                Button { showEditProfile = true } label: {
                    Text("Edit Profile")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity).padding(.vertical, 7)
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button { showGoLive = true } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "record.circle.fill")
                        Text("Go Live")
                    }
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity).padding(.vertical, 7)
                    .background(LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button {} label: {
                    Image(systemName: "person.badge.plus")
                        .font(.subheadline.bold())
                        .padding(.vertical, 7).padding(.horizontal, 10)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            // Active live stream prompt
            if let live = MockData.liveStreams.first(where: { $0.hostId == displayUser.id && $0.isActive }) {
                Button { showLiveStream = live } label: {
                    HStack {
                        Circle().fill(.red).frame(width: 8, height: 8)
                        Text("You're Live: \(live.title)")
                            .font(.subheadline.bold()).foregroundStyle(.red)
                        Spacer()
                        Text("\(live.viewerCount.shortFormatted()) watching")
                            .font(.caption).foregroundStyle(.secondary)
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private var avatarView: some View {
        Group {
            if let url = displayUser.profileImageURL {
                RemoteImage(url: url)
                    .frame(width: 86, height: 86)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(displayUser.artistType?.color ?? .gray, lineWidth: 2.5))
            } else {
                Circle()
                    .fill(LinearGradient(colors: displayUser.artistType?.gradient ?? [.gray, .gray], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 86, height: 86)
                    .overlay(
                        Text(displayUser.username.prefix(1).uppercased())
                            .font(.title.bold()).foregroundStyle(.white)
                    )
            }
        }
    }

    private func statColumn(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value.shortFormatted()).font(.subheadline.bold())
            Text(label).font(.caption)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Grid Tabs
    private var gridTabs: some View {
        HStack(spacing: 0) {
            tabButton(icon: "grid", index: 0)
            tabButton(icon: "person.crop.square", index: 1)
        }
    }

    private func tabButton(icon: String, index: Int) -> some View {
        Button { selectedGridTab = index } label: {
            Image(systemName: icon)
                .font(.title3)
                .frame(maxWidth: .infinity).padding(.vertical, 10)
                .foregroundStyle(selectedGridTab == index ? .primary : .secondary)
                .overlay(alignment: .bottom) {
                    if selectedGridTab == index {
                        Rectangle().frame(height: 1).foregroundStyle(.primary)
                    }
                }
        }
    }

    // MARK: - Post Grid
    private var postGrid: some View {
        let urls = (0..<min(displayUser.postsCount, 30)).map { MockData.gridImageURL(index: $0) }
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(urls, id: \.self) { url in
                RemoteImage(url: url)
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
            }
        }
    }
}

// MARK: - Settings Sheet
struct SettingsSheet: View {
    @Binding var isDarkMode: Bool
    var onSignOut: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundStyle(isDarkMode ? .indigo : .orange)
                            .frame(width: 28)
                        Text("Dark Mode")
                        Spacer()
                        Toggle("", isOn: $isDarkMode)
                            .labelsHidden()
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Changes how Rhythm Culture looks across the entire app.")
                }

                Section("Account") {
                    settingsRow(icon: "bell", color: .red, label: "Notifications")
                    settingsRow(icon: "lock.fill", color: .gray, label: "Privacy")
                    settingsRow(icon: "questionmark.circle", color: .blue, label: "Help & Support")
                }

                Section("About") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                            .frame(width: 28)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showSignOutConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .frame(width: 28)
                            Text("Sign Out")
                        }
                    }
                }
            }
            .confirmationDialog("Sign out of Rhythm Culture?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) { onSignOut() }
                Button("Cancel", role: .cancel) {}
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private func settingsRow(icon: String, color: Color, label: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 28)
            Text(label)
        }
    }
}
