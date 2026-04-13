// Masterclass.swift
// Paid video course model. Maps to Firestore `masterclasses` collection.
// Revenue split: instructor 80%, Rhythm Culture 20%.

import Foundation

struct Masterclass: Identifiable, Codable {
    let id: String
    let instructorId: String
    let instructorUsername: String
    let instructorDisplayName: String
    let instructorImageURL: String
    let title: String
    let description: String
    let price: Double           // RC takes 20% of every sale
    let artistType: ArtistType
    let lessonCount: Int
    let totalDurationMinutes: Int
    let rating: Double
    let reviewCount: Int
    let enrolledCount: Int
    let thumbnailURL: String
    let tags: [String]
    let createdAt: Date

    var rcEarnings: Double { price * 0.20 }
    var instructorEarnings: Double { price * 0.80 }

    var formattedDuration: String {
        let hours = totalDurationMinutes / 60
        let minutes = totalDurationMinutes % 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}
