// SellerTierBadgeView.swift
// Reusable seller tier badge — shown on profiles, post headers, and store cards.

import SwiftUI

struct SellerTierBadgeView: View {
    let tier: SellerTier
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 3 : 5) {
            Image(systemName: tier.icon)
                .font(compact ? .system(size: 8, weight: .bold) : .caption)
            if !compact {
                Text(tier.label)
                    .font(.caption.bold())
            }
        }
        .padding(.horizontal, compact ? 6 : 10)
        .padding(.vertical, compact ? 2 : 5)
        .background(
            LinearGradient(
                colors: tier.gradient.map { $0.opacity(0.2) },
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .foregroundStyle(tier.color)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(tier.color.opacity(0.35), lineWidth: 1))
    }
}

// MARK: - Full Tier Card (used in Store detail view)
struct SellerTierCardView: View {
    let tier: SellerTier
    var showPerks: Bool = true
    var nextTierRequirement: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: tier.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                    Image(systemName: tier.icon)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(tier.emoji)
                        Text(tier.label)
                            .font(.headline.bold())
                            .foregroundStyle(tier.color)
                    }
                    Text(tier.splitLabel)
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }

            if showPerks {
                Divider()
                Text("Tier Benefits").font(.caption.bold()).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(tier.perks, id: \.self) { perk in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption).foregroundStyle(tier.color)
                            Text(perk).font(.caption).foregroundStyle(.primary)
                        }
                    }
                }
            }

            if let req = nextTierRequirement {
                Divider()
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle").font(.caption).foregroundStyle(.secondary)
                    Text(req).font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(
            LinearGradient(colors: tier.gradient.map { $0.opacity(0.06) }, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tier.color.opacity(0.2), lineWidth: 1.5))
    }
}
