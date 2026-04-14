// BattlesView.swift
// Head-to-head artist battle feed with type filters and submission entry.

import SwiftUI

struct BattlesView: View {
    @State private var selectedFilter: ArtistType? = nil
    @State private var challenges = MockData.challenges
    @State private var showStartBattle = false

    private var filtered: [Challenge] {
        guard let filter = selectedFilter else { return challenges }
        return challenges.filter { $0.artistType == filter }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Filter chips
                    filterRow
                        .padding(.vertical, 12)

                    Divider()

                    // Battle cards
                    LazyVStack(spacing: 16) {
                        ForEach(filtered) { challenge in
                            ChallengeCardView(challenge: challenge)
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
                        Text("⚔️")
                        Text("Battles")
                            .font(.headline.bold())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showStartBattle = true } label: {
                        Image(systemName: "plus").foregroundStyle(.primary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                startBattleButton
            }
            .sheet(isPresented: $showStartBattle) {
                StartBattleView { newChallenge in
                    withAnimation { challenges.insert(newChallenge, at: 0) }
                }
                .presentationDetents([.large])
            }
        }
    }

    // MARK: – Filter Row
    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(label: "All", type: nil)

                ForEach([ArtistType.dancer, .rapper, .singer, .dj, .producer], id: \.self) { type in
                    filterChip(label: "\(type.emoji) \(type.rawValue)", type: type)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func filterChip(label: String, type: ArtistType?) -> some View {
        let isSelected = selectedFilter == type

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFilter = type
            }
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
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: – Start Battle CTA
    private var startBattleButton: some View {
        Button { showStartBattle = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                Text("Start a Battle")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(colors: [.purple, .pink, .orange], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Start Battle View
struct StartBattleView: View {
    var onCreate: (Challenge) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var selectedType: ArtistType = .dancer
    @State private var deadlineDays = 3

    private let artistTypes: [ArtistType] = [.dancer, .singer, .rapper, .dj, .producer]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Artist type chips
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Battle Type").font(.caption.bold()).foregroundStyle(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(artistTypes) { type in
                                    Button { selectedType = type } label: {
                                        Text("\(type.emoji) \(type.rawValue)")
                                            .font(.subheadline)
                                            .padding(.horizontal, 14).padding(.vertical, 8)
                                            .background(selectedType == type
                                                ? AnyShapeStyle(LinearGradient(colors: type.gradient, startPoint: .leading, endPoint: .trailing))
                                                : AnyShapeStyle(Color(.systemGray5)))
                                            .foregroundStyle(selectedType == type ? .white : .primary)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Battle Title").font(.caption.bold()).foregroundStyle(.secondary)
                        TextField("e.g. Best Freestyle — 60 Seconds", text: $title)
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Rules / Description").font(.caption.bold()).foregroundStyle(.secondary)
                        TextField("Describe the challenge...", text: $description, axis: .vertical)
                            .font(.subheadline)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Deadline
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Open for").font(.caption.bold()).foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            ForEach([1, 3, 7, 14], id: \.self) { days in
                                Button { deadlineDays = days } label: {
                                    Text("\(days)d")
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 16).padding(.vertical, 8)
                                        .background(deadlineDays == days
                                            ? AnyShapeStyle(LinearGradient(colors: selectedType.gradient, startPoint: .leading, endPoint: .trailing))
                                            : AnyShapeStyle(Color(.systemGray5)))
                                        .foregroundStyle(deadlineDays == days ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Info pill
                    HStack(spacing: 10) {
                        Image(systemName: "bolt.fill").foregroundStyle(.orange)
                        Text("Your battle will be open for others to accept and vote on immediately.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(Color.orange.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(20)
            }
            .navigationTitle("Start a Battle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Post") {
                        let challenge = Challenge(
                            id: UUID().uuidString,
                            title: title,
                            description: description.isEmpty ? "Show your skills." : description,
                            artistType: selectedType,
                            genre: selectedType.rawValue,
                            creatorId: MockData.currentUser.id,
                            creatorUsername: MockData.currentUser.username,
                            votesA: 0,
                            challengerId: nil,
                            challengerUsername: nil,
                            votesB: 0,
                            submissionCount: 0,
                            deadline: Date().addingTimeInterval(Double(deadlineDays) * 86400),
                            createdAt: .now
                        )
                        onCreate(challenge)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
