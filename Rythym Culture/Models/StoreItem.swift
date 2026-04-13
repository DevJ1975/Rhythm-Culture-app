// StoreItem.swift
// Artist marketplace item. Maps to Firestore `store` collection.
// Revenue split varies by seller tier: Elite 90/10 · Established 87/13 · Up & Coming 85/15.

import Foundation

enum StoreItemType: String, Codable, CaseIterable {
    case beat        = "Beat"
    case musicTrack  = "Track"
    case sample      = "Sample Pack"
    case preset      = "Preset"
    case merch       = "Merch"

    var icon: String {
        switch self {
        case .beat:       return "waveform"
        case .musicTrack: return "music.note"
        case .sample:     return "square.stack.3d.up"
        case .preset:     return "slider.horizontal.3"
        case .merch:      return "tshirt"
        }
    }
}

enum LicenseType: String, Codable {
    case nonExclusive = "Non-Exclusive"
    case exclusive    = "Exclusive"
    case unlimited    = "Unlimited"
    case free         = "Free"
}

struct StoreItem: Identifiable, Codable {
    let id: String
    let sellerId: String
    let sellerUsername: String
    let sellerDisplayName: String
    let sellerArtistType: ArtistType
    let sellerTier: SellerTier         // Platform seller tier — affects RC fee
    let type: StoreItemType
    let title: String
    let description: String
    let price: Double
    let licenseType: LicenseType?
    let genre: String?
    let bpm: Int?
    let keySignature: String?
    let tags: [String]
    let thumbnailURL: String
    var purchaseCount: Int
    var playCount: Int
    let createdAt: Date

    // Earnings split driven by seller's tier
    var rcEarnings: Double    { price * (sellerTier.rcFeePercent / 100) }
    var sellerEarnings: Double { price * (sellerTier.sellerEarnsPercent / 100) }
}
