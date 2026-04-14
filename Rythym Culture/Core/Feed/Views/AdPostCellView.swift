// AdPostCellView.swift
// Sponsored post card — visually consistent with PostCellView, clearly marked "Sponsored".

import SwiftUI

struct AdPostCellView: View {
    let ad: AdPost
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 10) {
                RemoteImage(url: ad.advertiserLogoURL)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(ad.advertiserName)
                            .font(.subheadline.bold())
                        sponsoredBadge
                    }
                    Text("Sponsored")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            // Media
            RemoteImage(url: ad.mediaURL)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipped()

            // Copy
            VStack(alignment: .leading, spacing: 6) {
                Text(ad.headline)
                    .font(.subheadline.bold())
                Text(ad.bodyText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                // CTA Button
                Button {
                    if let url = URL(string: ad.callToActionURL) {
                        openURL(url)
                    }
                } label: {
                    Text(ad.callToActionLabel)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(adGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color(.systemYellow).opacity(0.25), lineWidth: 1)
        )
    }

    private var sponsoredBadge: some View {
        Text("Sponsored")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color(red: 0.8, green: 0.65, blue: 0.0))
            .clipShape(Capsule())
    }

    private var adGradient: LinearGradient {
        switch ad.tier {
        case .premium:  return LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
        case .featured: return LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
        case .standard: return LinearGradient(colors: [Color(.systemGray2), Color(.systemGray3)], startPoint: .leading, endPoint: .trailing)
        }
    }
}
