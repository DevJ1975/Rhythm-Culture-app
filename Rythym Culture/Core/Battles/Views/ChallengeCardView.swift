// ChallengeCardView.swift
// Head-to-head battle card with live vote bars and Join/Vote actions.

import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge
    @State private var votedSide: VoteSide? = nil

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
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                .foregroundStyle(Color(.systemGray3))
                .frame(width: 52, height: 52)
                .overlay(Image(systemName: "plus").foregroundStyle(.secondary))

            Text("Open Spot").font(.caption.bold()).foregroundStyle(.secondary)
            Text("Be first!").font(.caption2).foregroundStyle(.secondary)

            Button { } label: {
                Text("Accept").font(.caption.bold())
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))
                    .foregroundStyle(.white).clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
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
            Button { } label: {
                Text("Submit Entry").font(.caption.bold())
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))
                    .foregroundStyle(.white).clipShape(Capsule())
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
