// RemoteImage.swift
// Reusable AsyncImage wrapper with loading placeholder and error fallback.

import SwiftUI

struct RemoteImage: View {
    let url: String
    var contentMode: ContentMode = .fill

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failure:
                Color(.systemGray5)
                    .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
            case .empty:
                Color(.systemGray6)
                    .overlay(ProgressView())
            @unknown default:
                Color(.systemGray6)
            }
        }
    }
}
