// CollabRequest.swift
// Collab board post. Maps to Firestore `collabs` collection.

import Foundation

struct CollabRequest: Identifiable, Codable {
    let id: String
    let creatorId: String
    let creatorUsername: String
    let creatorArtistType: ArtistType

    let title: String
    let description: String
    let projectType: String         // e.g. "Music Video", "EP", "Live Show"
    let lookingFor: [ArtistType]    // what roles they need filled
    let genre: String
    let location: String
    var isRemoteFriendly: Bool
    var applicantsCount: Int
    let createdAt: Date
}
