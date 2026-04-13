// CollabBoardView.swift
// Artist collab marketplace — post what you need, find who you need.

import SwiftUI

struct CollabBoardView: View {
    @State private var selectedFilter: ArtistType? = nil
    @State private var collabs = MockData.collabRequests

    private var filtered: [CollabRequest] {
        guard let filter = selectedFilter else { return collabs }
        return collabs.filter { $0.lookingFor.contains(filter) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    introBanner
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    filterRow
                        .padding(.vertical, 14)

                    Divider()

                    LazyVStack(spacing: 14) {
                        ForEach(filtered) { request in
                            CollabRequestCardView(request: request)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("🤝")
                        Text("Collabs")
                            .font(.headline.bold())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                postCollabButton
            }
        }
    }

    private var introBanner: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Find Your Team")
                    .font(.headline.bold())
                Text("Connect with artists who match your vision.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("🎭")
                .font(.largeTitle)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(.systemGray6), Color(.systemGray5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(label: "All", type: nil)
                ForEach(ArtistType.allCases) { type in
                    filterChip(label: "\(type.emoji) \(type.rawValue)", type: type)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func filterChip(label: String, type: ArtistType?) -> some View {
        let isSelected = selectedFilter == type
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = type }
        } label: {
            Text(label)
                .font(.subheadline.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected
                    ? AnyShapeStyle(LinearGradient(colors: type?.gradient ?? [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                    : AnyShapeStyle(Color(.systemGray5))
                )
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var postCollabButton: some View {
        Button { } label: {
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                Text("Post a Collab")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: – Collab Request Card
struct CollabRequestCardView: View {
    let request: CollabRequest
    @State private var applied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 10) {
                Circle()
                    .fill(LinearGradient(colors: request.creatorArtistType.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Text(request.creatorUsername.prefix(1).uppercased())
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("@\(request.creatorUsername)")
                            .font(.subheadline.bold())
                        ArtistBadgeView(artistType: request.creatorArtistType, compact: true)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.caption2)
                        Text(request.location)
                            .font(.caption)
                        if request.isRemoteFriendly {
                            Text("• Remote OK")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Text(request.genre)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }

            // Title & description
            VStack(alignment: .leading, spacing: 4) {
                Text(request.title)
                    .font(.headline)
                Text(request.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            // Looking for chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Text("Needs:")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    ForEach(request.lookingFor, id: \.self) { type in
                        Text("\(type.emoji) \(type.rawValue)")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(type.color.opacity(0.15))
                            .foregroundStyle(type.color)
                            .clipShape(Capsule())
                    }
                }
            }

            // Footer
            HStack {
                Label("\(request.applicantsCount) applied", systemImage: "person.3")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 8) {
                    Button { } label: {
                        Image(systemName: "message")
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                            .foregroundStyle(Color.primary)
                    }

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            applied.toggle()
                        }
                    } label: {
                        Text(applied ? "Applied ✓" : "Apply")
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                applied
                                ? AnyShapeStyle(Color(.systemGray4))
                                : AnyShapeStyle(LinearGradient(
                                    colors: request.creatorArtistType.gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                            )
                            .foregroundStyle(applied ? Color.secondary : Color.white)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    CollabBoardView()
}
