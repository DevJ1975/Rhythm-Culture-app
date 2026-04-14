// RemoteImage.swift
// Reusable AsyncImage wrapper with shimmer loading placeholder and error fallback.

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
                    .overlay(Image(systemName: "photo").foregroundStyle(.tertiary))
            case .empty:
                ShimmerBox()
            @unknown default:
                Color(.systemGray6)
            }
        }
    }
}

// MARK: - Shimmer Box

struct ShimmerBox: View {
    @State private var phase: CGFloat = -1.5

    var body: some View {
        GeometryReader { geo in
            Color(.systemGray5)
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.55), .clear],
                        startPoint: .init(x: phase, y: 0.5),
                        endPoint: .init(x: phase + 1, y: 0.5)
                    )
                    .frame(width: geo.size.width * 3)
                    .offset(x: geo.size.width * phase)
                )
                .clipped()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                phase = 1.5
            }
        }
    }
}

// MARK: - Shimmer modifier (for any view)

extension View {
    /// Overlays a shimmer effect. Use during loading states.
    func shimmer(isActive: Bool) -> some View {
        overlay(isActive ? AnyView(ShimmerBox()) : AnyView(EmptyView()))
    }
}
