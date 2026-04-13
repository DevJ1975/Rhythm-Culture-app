// ShowListing.swift
// Show Creation & IP licensing model. Maps to Supabase `show_listings`.
// Revenue split: artist 85% / Rhythm Culture 15%.

import SwiftUI

enum ShowScale: String, Codable, CaseIterable, Identifiable {
    case intimate = "Intimate"
    case midSize  = "Mid-Size"
    case arena    = "Arena"
    case any      = "Any Scale"

    var id: String { rawValue }

    var capacity: String {
        switch self {
        case .intimate: return "Under 500"
        case .midSize:  return "500–5,000"
        case .arena:    return "5,000+"
        case .any:      return "Flexible"
        }
    }
}

enum ShowLicenseTier: String, Codable, CaseIterable, Identifiable {
    case conceptOnly          = "Concept Only"
    case fullProductionRights = "Full Production Rights"
    case coCreation           = "Co-Creation"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .conceptOnly:
            return "Theme, narrative arc, mood board, creative direction notes."
        case .fullProductionRights:
            return "Full staging, cue sheets, costume direction, setlist, all production materials."
        case .coCreation:
            return "Creator joins your production as active collaborator. IP split negotiated."
        }
    }

    var color: Color {
        switch self {
        case .conceptOnly:          return .blue
        case .fullProductionRights: return .purple
        case .coCreation:           return .orange
        }
    }

    var icon: String {
        switch self {
        case .conceptOnly:          return "lightbulb"
        case .fullProductionRights: return "doc.richtext"
        case .coCreation:           return "person.2.badge.gearshape"
        }
    }
}

struct ShowTier: Identifiable, Codable {
    let id: String
    let tier: ShowLicenseTier
    let price: Double?              // nil = negotiated (co-creation)
    let isNegotiated: Bool
    let exclusiveOptionAvailable: Bool
    let exclusivePrice: Double?
    let territory: String?
}

struct ShowListing: Identifiable, Codable {
    let id: String
    let sellerId: String
    let sellerUsername: String
    let sellerDisplayName: String
    let sellerImageURL: String
    let title: String
    let description: String
    let genreTags: [String]
    let scale: ShowScale
    let moodBoardURLs: [String]
    let tiersAvailable: [ShowTier]
    let activeConceptLicenses: Int  // transparency: how many non-exclusive buyers
    let isActive: Bool
    let createdAt: Date
}
