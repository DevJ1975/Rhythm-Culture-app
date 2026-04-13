// AuthViewModel.swift
// Owns all authentication state. Will wire to Firebase Auth in Phase 2.

import SwiftUI

@Observable
final class AuthViewModel {
    var isAuthenticated: Bool = true   // TODO: revert to false when Firebase Auth is connected
    var currentUser: AppUser? = MockData.currentUser
    var isLoading: Bool = false
    var errorMessage: String? = nil
}
