// LiveStream.swift
// Live video stream model. Maps to Firestore `livestreams` collection.
// Future revenue: virtual gifts — RC takes 30% of gift revenue.

import Foundation

struct LiveStream: Identifiable, Codable {
    let id: String
    let hostId: String
    let hostUsername: String
    let hostDisplayName: String
    let hostImageURL: String
    let title: String
    var viewerCount: Int
    var isActive: Bool
    let startedAt: Date

    var durationLive: String {
        let seconds = Int(Date().timeIntervalSince(startedAt))
        let minutes = seconds / 60
        let hours = minutes / 60
        if hours > 0 { return "\(hours)h \(minutes % 60)m" }
        return "\(minutes)m"
    }
}
