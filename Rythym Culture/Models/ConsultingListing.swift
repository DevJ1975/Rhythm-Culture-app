// ConsultingListing.swift
// Artistic Direction & Creative Consulting model. Maps to Supabase `consulting_listings`.
// Revenue split: artist 85% / Rhythm Culture 15%.

import SwiftUI

enum AvailabilityStatus: String, Codable, CaseIterable {
    case open    = "Open"
    case limited = "Limited"
    case booked  = "Booked"

    var color: Color {
        switch self {
        case .open:    return .green
        case .limited: return .orange
        case .booked:  return .red
        }
    }

    var icon: String {
        switch self {
        case .open:    return "circle.fill"
        case .limited: return "circle.lefthalf.filled"
        case .booked:  return "circle.slash"
        }
    }
}

struct PastProject: Identifiable, Codable {
    let id: String
    let name: String
    let artist: String
    let year: Int
    let role: String
}

struct ConsultingListing: Identifiable, Codable {
    let id: String
    let sellerId: String
    let sellerUsername: String
    let sellerDisplayName: String
    let sellerImageURL: String
    let sellerArtistType: ArtistType
    let title: String
    let tagline: String
    let specialties: [String]
    let scopeStatement: String          // "What I do / What I don't do"
    let dayRate: Double
    let projectMinimum: Double
    let retainerAvailable: Bool
    let retainerRateMonthly: Double?
    let availabilityStatus: AvailabilityStatus
    let bookedThrough: Date?
    let pastProjects: [PastProject]
    let showreelURL: String?
    let portfolioURLs: [String]
    let isActive: Bool
    let createdAt: Date

    var rcFee: Double       { dayRate * 0.15 }
    var sellerEarns: Double { dayRate * 0.85 }
}
