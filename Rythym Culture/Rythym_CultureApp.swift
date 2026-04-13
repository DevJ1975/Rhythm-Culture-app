// Rythym_CultureApp.swift
// App entry point. AuthViewModel is injected into the environment for global access.

import SwiftUI

@main
struct Rythym_CultureApp: App {
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authViewModel)
        }
    }
}
