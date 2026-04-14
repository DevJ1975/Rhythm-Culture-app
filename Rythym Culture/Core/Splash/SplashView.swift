// SplashView.swift
// Animated fuchsia branded splash shown on every cold launch.

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.4
    @State private var logoOpacity: Double = 0
    @State private var textScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0

    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.0, blue: 0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Icon mark
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 110, height: 110)
                    Image(systemName: "waveform.and.music.mic")
                        .font(.system(size: 52, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Brand name
                Text("Rhythm Culture")
                    .font(.system(size: 36, weight: .black, design: .default))
                    .foregroundStyle(.white)
                    .scaleEffect(textScale)
                    .opacity(textOpacity)

                // Tagline
                Text("Where Artists Rise")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .tracking(2)
                    .opacity(subtitleOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.3)) {
                textScale = 1.0
                textOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.6)) {
                subtitleOpacity = 1.0
            }
        }
    }
}
