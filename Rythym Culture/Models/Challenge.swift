// Challenge.swift
// Battle/challenge model. Maps to Firestore `challenges` collection.

import Foundation

struct Challenge: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let artistType: ArtistType
    let genre: String

    // Challenger A (original creator)
    let creatorId: String
    let creatorUsername: String
    var votesA: Int

    // Challenger B (opponent) — nil means open challenge
    let challengerId: String?
    let challengerUsername: String?
    var votesB: Int

    var submissionCount: Int
    let deadline: Date
    let createdAt: Date

    var isOpen: Bool { challengerId == nil }

    var totalVotes: Int { votesA + votesB }

    var percentA: Double {
        guard totalVotes > 0 else { return 0.5 }
        return Double(votesA) / Double(totalVotes)
    }
}
