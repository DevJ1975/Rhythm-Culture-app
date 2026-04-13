// CoachingListing.swift
// Movement coaching & session model. Maps to Supabase `coaching_listings` table.
// Revenue split: artist 85% / Rhythm Culture 15%.

import SwiftUI

enum CoachingFormatType: String, Codable, CaseIterable, Identifiable {
    case privateSession = "Private"
    case group          = "Group"
    case recorded       = "Recorded"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .privateSession: return "person"
        case .group:          return "person.3"
        case .recorded:       return "play.circle"
        }
    }

    var description: String {
        switch self {
        case .privateSession: return "1-on-1 session, personalized to your level and goals."
        case .group:          return "Small group intensive with capped enrollment."
        case .recorded:       return "Pre-recorded technique breakdown, available instantly."
        }
    }
}

struct CoachingFormat: Identifiable, Codable {
    let id: String
    let type: CoachingFormatType
    let price: Double
    let durationMinutes: Int?   // nil for recorded
    let groupCapacity: Int?     // group only
}

struct CoachingListing: Identifiable, Codable {
    let id: String
    let sellerId: String
    let sellerUsername: String
    let sellerDisplayName: String
    let sellerImageURL: String
    let sellerArtistType: ArtistType
    let title: String
    let description: String
    let styleTags: [String]
    let formats: [CoachingFormat]
    let thumbnailURL: String
    let verifiedCredits: [String]
    let rating: Double
    let reviewCount: Int
    let totalStudents: Int
    let isActive: Bool
    let createdAt: Date

    var startingPrice: Double {
        formats.map(\.price).min() ?? 0
    }

    var rcFee: Double    { startingPrice * 0.15 }
    var sellerEarns: Double { startingPrice * 0.85 }
}
