// MockData+Ads.swift
// Mock sponsored posts — replace with real ad server before launch.

import Foundation

extension MockData {

    static let ads: [AdPost] = [
        AdPost(
            id: "ad_1",
            advertiserName: "Native Instruments",
            advertiserLogoURL: "https://i.pravatar.cc/200?img=50",
            headline: "Make beats that move the culture.",
            bodyText: "Maschine+ — the standalone beat-making studio built for artists on the go. No laptop needed.",
            mediaURL: "https://picsum.photos/id/96/800/800",
            callToActionLabel: "Shop Now",
            callToActionURL: "https://www.native-instruments.com",
            tier: .featured
        ),
        AdPost(
            id: "ad_2",
            advertiserName: "Eventbrite",
            advertiserLogoURL: "https://i.pravatar.cc/200?img=51",
            headline: "Sell out your next show.",
            bodyText: "Eventbrite makes it easy to list, promote, and sell tickets for any live performance — big or small.",
            mediaURL: "https://picsum.photos/id/167/800/800",
            callToActionLabel: "List Your Event",
            callToActionURL: "https://www.eventbrite.com",
            tier: .standard
        ),
        AdPost(
            id: "ad_3",
            advertiserName: "Splice",
            advertiserLogoURL: "https://i.pravatar.cc/200?img=52",
            headline: "Millions of samples. One subscription.",
            bodyText: "Find the perfect sound for your next drop. Splice gives you access to the world's largest royalty-free sample library.",
            mediaURL: "https://picsum.photos/id/145/800/800",
            callToActionLabel: "Try Free",
            callToActionURL: "https://splice.com",
            tier: .premium
        ),
    ]

    // Returns an ad to inject after a given post index (every 5th slot).
    static func ad(afterIndex index: Int) -> AdPost? {
        guard (index + 1) % 5 == 0 else { return nil }
        let adIndex = ((index + 1) / 5 - 1) % ads.count
        return ads[adIndex]
    }
}
