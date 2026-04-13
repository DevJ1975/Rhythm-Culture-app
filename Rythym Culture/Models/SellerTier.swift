// SellerTier.swift
// Platform seller tiers — Elite, Established, Up & Coming.
// Tier is based on a seller's cumulative store sales on Rhythm Culture.

import Foundation
import SwiftUI

enum SellerTier: Int, Codable, Comparable, CaseIterable, Identifiable {
    case upAndComing = 0
    case established = 1
    case elite       = 2

    var id: Int { rawValue }

    // MARK: - Comparable
    static func < (lhs: SellerTier, rhs: SellerTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    // MARK: - Tier from sales count
    /// Returns nil if totalSales == 0 (user has never sold anything).
    static func from(totalSales: Int) -> SellerTier? {
        guard totalSales > 0 else { return nil }
        if totalSales >= 800 { return .elite }
        if totalSales >= 100 { return .established }
        return .upAndComing
    }

    // MARK: - Identity
    var label: String {
        switch self {
        case .elite:       return "Elite"
        case .established: return "Established"
        case .upAndComing: return "Up & Coming"
        }
    }

    var emoji: String {
        switch self {
        case .elite:       return "👑"
        case .established: return "⭐"
        case .upAndComing: return "🌱"
        }
    }

    var icon: String {
        switch self {
        case .elite:       return "crown.fill"
        case .established: return "star.fill"
        case .upAndComing: return "arrow.up.circle.fill"
        }
    }

    // MARK: - Revenue split
    var rcFeePercent: Double {
        switch self {
        case .elite:       return 10.0
        case .established: return 13.0
        case .upAndComing: return 15.0
        }
    }

    var sellerEarnsPercent: Double { 100.0 - rcFeePercent }

    var splitLabel: String {
        "You keep \(Int(sellerEarnsPercent))% · RC keeps \(Int(rcFeePercent))%"
    }

    // MARK: - Progression
    var nextTierRequirement: String? {
        switch self {
        case .elite:       return nil
        case .established: return "Reach 800 total sales to unlock Elite"
        case .upAndComing: return "Reach 100 total sales to unlock Established"
        }
    }

    var nextTier: SellerTier? {
        switch self {
        case .upAndComing: return .established
        case .established: return .elite
        case .elite:       return nil
        }
    }

    // MARK: - Perks
    var perks: [String] {
        switch self {
        case .elite:
            return [
                "Featured in Elite Picks at top of Store",
                "Lowest platform fee — RC keeps only 10%",
                "👑 Elite crown badge on profile & posts",
                "Priority customer support",
                "Early access to new platform features",
                "Eligible for Rhythm Culture promo campaigns"
            ]
        case .established:
            return [
                "Boosted search ranking in Store",
                "Reduced platform fee — RC keeps 13%",
                "⭐ Established badge on profile & posts",
                "Access to seller analytics dashboard",
                "Promotional email inclusion"
            ]
        case .upAndComing:
            return [
                "Discoverable by all buyers in Store",
                "Standard platform fee — RC keeps 15%",
                "🌱 Up & Coming badge on profile & posts",
                "Mentorship matching with Elite sellers",
                "Community support in RC Creator group"
            ]
        }
    }
}

// MARK: - SwiftUI Colors (not Codable — extension kept separate)
extension SellerTier {
    var color: Color {
        switch self {
        case .elite:       return Color(red: 0.80, green: 0.60, blue: 0.00) // deep gold
        case .established: return .blue
        case .upAndComing: return .green
        }
    }

    var gradient: [Color] {
        switch self {
        case .elite:       return [Color(red: 1.0, green: 0.85, blue: 0.2), Color(red: 0.80, green: 0.50, blue: 0.0)]
        case .established: return [.blue, .cyan]
        case .upAndComing: return [.green, .teal]
        }
    }
}
