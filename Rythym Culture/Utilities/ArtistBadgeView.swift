// ArtistBadgeView.swift
// Reusable artist type badge shown on profiles, posts, and collab cards.

import SwiftUI

struct ArtistBadgeView: View {
    let artistType: ArtistType
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 3 : 4) {
            Text(artistType.emoji)
                .font(compact ? .caption2 : .caption)
            if !compact {
                Text(artistType.rawValue)
                    .font(.caption.bold())
            }
        }
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, compact ? 2 : 4)
        .background(artistType.color.opacity(0.15))
        .foregroundStyle(artistType.color)
        .clipShape(Capsule())
    }
}
