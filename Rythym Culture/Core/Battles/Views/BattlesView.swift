// BattlesView.swift
// Head-to-head artist battle feed with type filters and submission entry.

import SwiftUI

struct BattlesView: View {
    @State private var selectedFilter: ArtistType? = nil
    @State private var challenges = MockData.challenges

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
                    Button {
                        // Phase 3: create new battle
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                startBattleButton
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
        Button {
            // Phase 3: create challenge sheet
        } label: {
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

#Preview {
    BattlesView()
}
