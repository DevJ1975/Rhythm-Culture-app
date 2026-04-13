// OnboardingView.swift
// First-launch artist type selection shown after signup.

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var selectedType: ArtistType? = nil
    @State private var isLoading = false

    private let artistTypes: [(type: ArtistType, description: String)] = [
        (.dancer,       "Choreographer, performer, movement artist"),
        (.singer,       "Vocalist, songwriter, recording artist"),
        (.rapper,       "MC, lyricist, hip-hop artist"),
        (.dj,           "DJ, turntablist, live selector"),
        (.producer,     "Beatmaker, producer, sound designer"),
        (.photographer, "Performance & event photographer"),
        (.videographer, "Music video & live content creator"),
        (.poet,         "Spoken word, slam poet, writer"),
        (.multiArtist,  "Multiple disciplines — wear them all"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("🎭")
                    .font(.system(size: 52))
                Text("What kind of artist are you?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text("Your artist type shapes your experience — battles, auditions, and connections are tailored to you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 48).padding(.bottom, 24)

            // Artist type grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(artistTypes, id: \.type) { item in
                        ArtistTypeCard(
                            type: item.type,
                            description: item.description,
                            isSelected: selectedType == item.type
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedType = item.type
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 6) {
                if let type = selectedType {
                    Text("You selected: \(type.emoji) \(type.rawValue)")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Button {
                    guard selectedType != nil else { return }
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(selectedType == nil ? "Select your artist type" : "Continue →")
                                .font(.headline.bold())
                        }
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(selectedType != nil
                        ? AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                        : AnyShapeStyle(Color(.systemGray4)))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(selectedType == nil || isLoading)
                .padding(.horizontal, 20).padding(.bottom, 8)
            }
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - Artist Type Card
private struct ArtistTypeCard: View {
    let type: ArtistType
    let description: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(type.emoji).font(.title2)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(type.color)
                    }
                }
                Text(type.rawValue).font(.subheadline.bold())
                Text(description).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            .padding(14)
            .background(isSelected ? type.color.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? type.color : Color.clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}
