// ChallengeCardView.swift
// Head-to-head battle card with live vote bars and Join/Vote actions.

import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge
    @State private var votedSide: VoteSide? = nil
    @State private var hasAccepted = false
    @State private var hasSubmitted = false
    @State private var showSubmitSheet = false
    @State private var showAcceptConfirm = false

    enum VoteSide { case a, b }

    private var gradientColors: [Color] { challenge.artistType.gradient }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader
            vsSection.padding(.horizontal, 16).padding(.top, 16)
            voteBar.padding(.horizontal, 16).padding(.top, 12)
            cardFooter.padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    // MARK: – Header
    private var cardHeader: some View {
        HStack(spacing: 8) {
            Text(challenge.artistType.emoji).font(.title3)
            Text(challenge.artistType.rawValue.uppercased() + " BATTLE")
                .font(.caption.bold()).foregroundStyle(.white).tracking(1.2)
            Spacer()
            Label(timeRemaining, systemImage: "clock")
                .font(.caption.bold()).foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 16, bottomLeadingRadius: 0,
            bottomTrailingRadius: 0, topTrailingRadius: 16
        ))
    }

    // MARK: – VS Section
    private var vsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(challenge.title).font(.headline).lineLimit(2)

            HStack(alignment: .top, spacing: 12) {
                competitorColumn(username: challenge.creatorUsername,
                                 votes: challenge.votesA, side: .a,
                                 isWinning: challenge.votesA >= challenge.votesB)

                Text("VS")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.secondary)
                    .frame(maxHeight: .infinity)
                    .padding(.top, 12)

                if challenge.isOpen {
                    openChallengerColumn
                } else {
                    competitorColumn(username: challenge.challengerUsername ?? "",
                                     votes: challenge.votesB, side: .b,
                                     isWinning: challenge.votesB > challenge.votesA)
                }
            }
        }
    }

    private func competitorColumn(username: String, votes: Int, side: VoteSide, isWinning: Bool) -> some View {
        VStack(spacing: 8) {
            Circle()
                .frame(width: 52, height: 52)
                .overlay(
                    RemoteImage(url: MockData.avatarURL(username))
                        .clipShape(Circle())
                )
                .clipShape(Circle())
                .overlay(alignment: .topTrailing) {
                    if isWinning && !challenge.isOpen {
                        Image(systemName: "crown.fill")
                            .font(.caption).foregroundStyle(.yellow)
                            .offset(x: 4, y: -4)
                    }
                }

            Text("@\(username)").font(.caption.bold()).lineLimit(1)
            Text(votes.shortFormatted()).font(.caption2).foregroundStyle(.secondary)

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { votedSide = side }
            } label: {
                Text(votedSide == side ? "Voted ✓" : "Vote")
                    .font(.caption.bold())
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(votedSide == side ? Color(gradientColors[0]) : Color(.systemGray5))
                    .foregroundStyle(votedSide == side ? Color.white : Color.primary)
                    .clipShape(Capsule())
            }
            .disabled(votedSide != nil)
        }
        .frame(maxWidth: .infinity)
    }

    private var openChallengerColumn: some View {
        VStack(spacing: 8) {
            if hasAccepted {
                RemoteImage(url: MockData.avatarURL(MockData.currentUser.id))
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.green, lineWidth: 2))
            } else {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                    .foregroundStyle(Color(.systemGray3))
                    .frame(width: 52, height: 52)
                    .overlay(Image(systemName: "plus").foregroundStyle(.secondary))
            }

            Text(hasAccepted ? "@\(MockData.currentUser.username)" : "Open Spot")
                .font(.caption.bold())
                .foregroundStyle(hasAccepted ? .primary : .secondary)
                .lineLimit(1)
            Text(hasAccepted ? "You accepted!" : "Be first!")
                .font(.caption2)
                .foregroundStyle(hasAccepted ? .green : .secondary)

            Button {
                if !hasAccepted { showAcceptConfirm = true }
            } label: {
                Text(hasAccepted ? "Accepted ✓" : "Accept")
                    .font(.caption.bold())
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(hasAccepted
                        ? AnyShapeStyle(Color.green)
                        : AnyShapeStyle(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)))
                    .foregroundStyle(.white).clipShape(Capsule())
            }
            .disabled(hasAccepted)
        }
        .frame(maxWidth: .infinity)
        .confirmationDialog("Accept this battle?", isPresented: $showAcceptConfirm, titleVisibility: .visible) {
            Button("Accept Challenge") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { hasAccepted = true }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll be listed as the challenger in \"\(challenge.title)\"")
        }
    }

    // MARK: – Vote Bar
    private var voteBar: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(8, geo.size.width * CGFloat(challenge.percentA)))
                    RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray4))
                }
            }
            .frame(height: 6)

            if !challenge.isOpen {
                HStack {
                    Text("\(Int(challenge.percentA * 100))%").font(.caption2.bold()).foregroundStyle(gradientColors[0])
                    Spacer()
                    Text("\(Int((1 - challenge.percentA) * 100))%").font(.caption2.bold()).foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: – Footer
    private var cardFooter: some View {
        HStack {
            Label("\(challenge.submissionCount) submissions", systemImage: "play.circle")
                .font(.caption).foregroundStyle(.secondary)
            Spacer()
            Button { if !hasSubmitted { showSubmitSheet = true } } label: {
                Text(hasSubmitted ? "Submitted ✓" : "Submit Entry")
                    .font(.caption.bold())
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(hasSubmitted
                        ? AnyShapeStyle(Color.green)
                        : AnyShapeStyle(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)))
                    .foregroundStyle(.white).clipShape(Capsule())
            }
            .disabled(hasSubmitted)
            .sheet(isPresented: $showSubmitSheet) {
                SubmitEntryView(challenge: challenge) {
                    withAnimation { hasSubmitted = true }
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var timeRemaining: String {
        let seconds = Int(challenge.deadline.timeIntervalSinceNow)
        guard seconds > 0 else { return "Ended" }
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        return days > 0 ? "\(days)d left" : "\(hours)h left"
    }
}

// MARK: - Submit Entry View
struct SubmitEntryView: View {
    let challenge: Challenge
    var onSubmit: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var note = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Challenge info pill
                HStack(spacing: 8) {
                    Text(challenge.artistType.emoji).font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(challenge.title).font(.subheadline.bold()).lineLimit(1)
                        Text(challenge.artistType.rawValue + " Battle")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Upload placeholder
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
                    .frame(height: 140)
                    .overlay(
                        VStack(spacing: 10) {
                            Image(systemName: "video.badge.plus")
                                .font(.system(size: 36)).foregroundStyle(.secondary)
                            Text("Tap to upload your entry")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    )

                // Optional note
                TextField("Add a note about your entry (optional)...", text: $note, axis: .vertical)
                    .font(.subheadline)
                    .lineLimit(2...4)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Spacer()
            }
            .padding(20)
            .navigationTitle("Submit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Submit") {
                        onSubmit()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(challenge.artistType.gradient.first ?? .purple))
                }
            }
        }
    }
}
