// ArtistType.swift
// Core artist classification used across profiles, posts, and discovery.

import SwiftUI

enum ArtistType: String, Codable, CaseIterable, Identifiable {
    case dancer       = "Dancer"
    case singer       = "Singer"
    case rapper       = "Rapper"
    case dj           = "DJ"
    case producer     = "Producer"
    case photographer = "Photographer"
    case videographer = "Videographer"
    case poet         = "Poet"
    case multiArtist  = "Multi-Artist"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .dancer:       return "💃"
        case .singer:       return "🎤"
        case .rapper:       return "🎙️"
        case .dj:           return "🎧"
        case .producer:     return "🎹"
        case .photographer: return "📸"
        case .videographer: return "🎬"
        case .poet:         return "✍️"
        case .multiArtist:  return "⭐"
        }
    }

    var color: Color {
        switch self {
        case .dancer:       return .pink
        case .singer:       return .blue
        case .rapper:       return .orange
        case .dj:           return .purple
        case .producer:     return .teal
        case .photographer: return .green
        case .videographer: return .red
        case .poet:         return .indigo
        case .multiArtist:  return .yellow
        }
    }

    var gradient: [Color] {
        switch self {
        case .dancer:       return [.pink, .purple]
        case .singer:       return [.blue, .cyan]
        case .rapper:       return [.orange, .red]
        case .dj:           return [.purple, .indigo]
        case .producer:     return [.teal, .green]
        case .photographer: return [.green, .teal]
        case .videographer: return [.red, .orange]
        case .poet:         return [.indigo, .purple]
        case .multiArtist:  return [.yellow, .orange]
        }
    }
}
