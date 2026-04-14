// AuthViewModel.swift
// Owns all authentication state, wired to Supabase Auth.

import SwiftUI
import Supabase

@Observable
final class AuthViewModel {
    var isAuthenticated = false
    var currentUser: AppUser? = nil
    var isLoading = false
    var errorMessage: String? = nil

    init() {
        Task { await checkSession() }
    }

    // MARK: - Session Restore

    /// Called on launch — restores an existing Supabase session from the Keychain.
    @MainActor
    func checkSession() async {
        do {
            let session = try await supabase.auth.session
            await loadProfile(userId: session.user.id.uuidString)
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }

    // MARK: - Sign In

    @MainActor
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            await loadProfile(userId: session.user.id.uuidString)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Sign Up

    @MainActor
    func signUp(email: String, password: String, username: String, displayName: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await supabase.auth.signUp(email: email, password: password)
            let user = response.user

            // Insert a matching row in the public.profiles table
            let profile = ProfileInsert(
                id: user.id.uuidString,
                username: username,
                displayName: displayName,
                email: email
            )
            try await supabase.from("profiles").insert(profile).execute()

            if response.session != nil {
                // Email confirmation disabled — user is signed in immediately
                await loadProfile(userId: user.id.uuidString)
                isAuthenticated = true
            } else {
                // Email confirmation required — prompt the user to check their inbox
                errorMessage = "Check your email to confirm your account, then sign in."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Update Profile (local, for Edit Profile UI)

    @MainActor
    func updateCurrentUser(_ user: AppUser) {
        currentUser = user
    }

    // MARK: - Sign Out

    @MainActor
    func signOut() async {
        try? await supabase.auth.signOut()
        isAuthenticated = false
        currentUser = nil
    }

    // MARK: - Profile Load

    @MainActor
    private func loadProfile(userId: String) async {
        do {
            let profile: AppUser = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            currentUser = profile
        } catch {
            // Profile row not found or decode error — currentUser stays nil
        }
    }
}

// MARK: - Insert DTO

/// Minimal encodable type for inserting a new profile row.
private struct ProfileInsert: Encodable {
    let id: String
    let username: String
    let displayName: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case id, username, email
        case displayName = "display_name"
    }
}
