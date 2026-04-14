// StoryViewerView.swift
// Fullscreen story viewer with animated progress bar and swipe navigation.

import SwiftUI

struct StoryViewerView: View {
    let stories: [StoryItem]
    var startIndex: Int = 0
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    @State private var isPaused = false

    private let duration: Double = 5.0

    init(stories: [StoryItem], startIndex: Int = 0) {
        self.stories = stories
        self.startIndex = startIndex
        _currentIndex = State(initialValue: startIndex)
    }

    var current: StoryItem { stories[currentIndex] }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Background image
            if let url = current.imageURL {
                RemoteImage(url: url, contentMode: .fill)
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.25))
            } else {
                LinearGradient(
                    colors: current.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // Progress bars
                progressBars
                    .padding(.horizontal, 12)
                    .padding(.top, 56)

                // Header
                HStack(spacing: 10) {
                    Circle()
                        .frame(width: 38, height: 38)
                        .overlay(
                            Group {
                                if let url = current.imageURL {
                                    RemoteImage(url: url).clipShape(Circle())
                                } else {
                                    Circle().fill(LinearGradient(colors: current.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                }
                            }
                        )
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 1) {
                        Text(current.isSelf ? "Your Story" : current.username)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                        Text(current.isSelf ? "Tap to add" : "Now")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()
            }

            // Tap zones: left = previous, right = next
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { goToPrevious() }
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { goToNext() }
            }
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.height > 80 { dismiss() }
                    }
            )
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .onChange(of: currentIndex) {
            progress = 0
            stopTimer()
            startTimer()
        }
        .statusBarHidden()
    }

    // MARK: - Progress Bars

    private var progressBars: some View {
        HStack(spacing: 4) {
            ForEach(stories.indices, id: \.self) { i in
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.35))
                        Capsule()
                            .fill(.white)
                            .frame(width: barWidth(for: i, totalWidth: geo.size.width))
                    }
                }
                .frame(height: 2.5)
            }
        }
    }

    private func barWidth(for index: Int, totalWidth: CGFloat) -> CGFloat {
        if index < currentIndex { return totalWidth }
        if index > currentIndex { return 0 }
        return totalWidth * progress
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard !isPaused else { return }
            progress += 0.05 / duration
            if progress >= 1 { goToNext() }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func goToNext() {
        if currentIndex < stories.count - 1 {
            currentIndex += 1
        } else {
            dismiss()
        }
    }

    private func goToPrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            progress = 0
        }
    }
}
