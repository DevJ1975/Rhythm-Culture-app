// Audition.swift
// Formal talent call model. Maps to Firestore `auditions` collection.

import Foundation

enum AuditionProjectType: String, Codable, CaseIterable {
    case worldTour    = "World Tour"
    case musicVideo   = "Music Video"
    case broadway     = "Broadway"
    case festival     = "Festival"
    case recording    = "Recording"
    case tvShow       = "TV Show"
    case commercial   = "Commercial"

    var icon: String {
        switch self {
        case .worldTour:  return "airplane"
        case .musicVideo: return "video"
        case .broadway:   return "theatermasks"
        case .festival:   return "music.mic"
        case .recording:  return "mic"
        case .tvShow:     return "tv"
        case .commercial: return "star"
        }
    }
}

enum CompensationType: String, Codable {
    case paid           = "Paid"
    case paidTravel     = "Paid + Travel"
    case volunteer      = "Volunteer"
    case tbd            = "TBD"
}

struct Audition: Identifiable, Codable {
    let id: String
    let posterId: String
    let posterUsername: String
    let posterDisplayName: String
    let posterArtistType: ArtistType
    let posterImageURL: String
    let projectName: String
    let projectType: AuditionProjectType
    let title: String
    let description: String
    let lookingFor: [ArtistType]
    let compensation: CompensationType
    let compensationAmount: String?     // e.g. "$500/week"
    let location: String
    var isRemoteFriendly: Bool
    let deadline: Date
    var submissionCount: Int
    let createdAt: Date

    var daysUntilDeadline: Int {
        max(0, Calendar.current.dateComponents([.day], from: .now, to: deadline).day ?? 0)
    }

    var isUrgent: Bool { daysUntilDeadline <= 3 }
}
