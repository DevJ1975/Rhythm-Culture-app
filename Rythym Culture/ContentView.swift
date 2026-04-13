// ContentView.swift
// Root navigation gate — auth flow, onboarding, then main app.

import SwiftUI

struct RootView: View {
    @Environment(AuthViewModel.self) var authViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .sheet(isPresented: .constant(!hasCompletedOnboarding)) {
                        OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                            .interactiveDismissDisabled()
                    }
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
    }
}
