// Space.swift
// Live audio room model. Maps to Firestore `spaces` collection.

import Foundation

struct Space: Identifiable, Codable {
    let id: String
    let hostId: String
    let hostUsername: String
    let title: String
    let topic: String?
    let artistType: ArtistType?
    var speakerUsernames: [String]
    var listenerCount: Int
    var isLive: Bool
    let scheduledFor: Date?
    let startedAt: Date?
    let createdAt: Date
}
