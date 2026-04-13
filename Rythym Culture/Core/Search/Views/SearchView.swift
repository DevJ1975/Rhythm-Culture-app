// SearchView.swift
// Explore tab — artist discovery, search, and visual grid.

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedArtistType: ArtistType? = nil
    @State private var isRefreshing = false

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]

    var searchResults: [AppUser] {
        guard !searchText.isEmpty else { return [] }
        return MockData.allUsers.filter {
            $0.username.localizedCaseInsensitiveContains(searchText) ||
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            ($0.artistType?.rawValue.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var filteredArtists: [AppUser] {
        guard let type = selectedArtistType else { return MockData.allUsers }
        return MockData.allUsers.filter { $0.artistType == type }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if searchText.isEmpty {
                    exploreContent
                } else {
                    searchResultsContent
                }
            }
            .refreshable { try? await Task.sleep(nanoseconds: 800_000_000) }
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search artists, genres, styles...")
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Explore (empty search)
    private var exploreContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Artist type filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(label: "Everyone", type: nil)
                    ForEach([ArtistType.dancer, .singer, .rapper, .dj, .producer, .photographer]) { type in
                        filterChip(label: type.emoji + " " + type.rawValue, type: type)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
            }

            // Top Artists strip
            VStack(alignment: .leading, spacing: 10) {
                Text("Top Artists")
                    .font(.headline.bold())
                    .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(filteredArtists) { user in
                            NavigationLink(destination: ProfileView(user: user)) {
                                ArtistDiscoveryCard(user: user)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 16)

            Divider()

            // Photo grid
            Text("Explore")
                .font(.headline.bold())
                .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 8)

            if filteredArtists.isEmpty {
                EmptyStateView(icon: "person.2.slash",
                               title: "No artists found",
                               subtitle: "Try a different filter")
            } else {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(0..<36, id: \.self) { index in
                        exploreTile(index: index)
                    }
                }
            }
        }
    }

    // MARK: - Search results
    private var searchResultsContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if searchResults.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No results for \"\(searchText)\"",
                    subtitle: "Try searching for an artist name, style, or genre"
                )
                .padding(.top, 60)
            } else {
                Text("People")
                    .font(.headline.bold())
                    .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 8)

                LazyVStack(spacing: 0) {
                    ForEach(searchResults) { user in
                        NavigationLink(destination: ProfileView(user: user)) {
                            UserSearchRow(user: user)
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 74)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func exploreTile(index: Int) -> some View {
        let isFeatured = index % 7 == 0
        RemoteImage(url: MockData.gridImageURL(index: index + 50))
            .frame(maxWidth: .infinity)
            .aspectRatio(isFeatured ? 0.5 : 1, contentMode: .fit)
            .clipped()
            .overlay(alignment: .bottomTrailing) {
                if isFeatured {
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                        .padding(6)
                }
            }
    }

    private func filterChip(label: String, type: ArtistType?) -> some View {
        let isSelected = selectedArtistType == type
        return Button { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedArtistType = type } } label: {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(isSelected
                    ? AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                    : AnyShapeStyle(Color(.systemGray5)))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Artist Discovery Card
struct ArtistDiscoveryCard: View {
    let user: AppUser
    @State private var isFollowing = false

    var body: some View {
        VStack(spacing: 8) {
            RemoteImage(url: user.profileImageURL ?? MockData.avatarURL(user.id))
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .overlay(Circle().stroke(user.artistType?.color ?? .gray, lineWidth: 2))

            VStack(spacing: 2) {
                Text(user.username)
                    .font(.caption.bold())
                    .lineLimit(1)
                if let type = user.artistType {
                    Text(type.emoji + " " + type.rawValue)
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Text(user.followersCount.shortFormatted())
                    .font(.caption2).foregroundStyle(.secondary)
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isFollowing.toggle() }
            } label: {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.caption.bold())
                    .padding(.horizontal, 14).padding(.vertical, 5)
                    .background(isFollowing ? AnyShapeStyle(Color(.systemGray5)) : AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)))
                    .foregroundStyle(isFollowing ? AnyShapeStyle(.primary) : AnyShapeStyle(Color.white))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 100)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}

// MARK: - User Search Row
struct UserSearchRow: View {
    let user: AppUser
    @State private var isFollowing = false

    var body: some View {
        HStack(spacing: 12) {
            RemoteImage(url: user.profileImageURL ?? MockData.avatarURL(user.id))
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(user.artistType?.color ?? .gray, lineWidth: 1.5))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(user.displayName).font(.subheadline.bold())
                    if let type = user.artistType {
                        ArtistBadgeView(artistType: type, compact: true)
                    }
                    if let tier = MockData.sellerTier(forUserId: user.id) {
                        SellerTierBadgeView(tier: tier, compact: true)
                    }
                }
                Text("@\(user.username)").font(.caption).foregroundStyle(.secondary)
                Text(user.followersCount.shortFormatted() + " followers").font(.caption2).foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isFollowing.toggle() }
            } label: {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.caption.bold())
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(isFollowing ? AnyShapeStyle(Color(.systemGray5)) : AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)))
                    .foregroundStyle(isFollowing ? AnyShapeStyle(.primary) : AnyShapeStyle(Color.white))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }
}
