// Rythym_CultureApp.swift
// App entry point. AuthViewModel is injected into the environment for global access.

import SwiftUI

@main
struct Rythym_CultureApp: App {
    @State private var authViewModel = AuthViewModel()
    @State private var isShowingSplash = true

    init() {
        // Increase URL cache so images don't re-fetch on every back-navigation
        URLCache.shared = URLCache(memoryCapacity: 50_000_000, diskCapacity: 200_000_000)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environment(authViewModel)

                if isShowingSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeOut(duration: 0.5), value: isShowingSplash)
            .task {
                try? await Task.sleep(for: .seconds(2.2))
                isShowingSplash = false
            }
        }
    }
}
