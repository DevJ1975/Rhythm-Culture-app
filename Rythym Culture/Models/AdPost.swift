// AdPost.swift
// Sponsored post model — injected into feed at regular intervals.

import Foundation

enum AdTier: String, Codable {
    case standard  // basic placement
    case featured  // priority placement + larger visual
    case premium   // top-of-feed guaranteed slot
}

struct AdPost: Identifiable {
    let id: String
    let advertiserName: String
    let advertiserLogoURL: String
    let headline: String
    let bodyText: String
    let mediaURL: String
    let callToActionLabel: String
    let callToActionURL: String
    let tier: AdTier
}
