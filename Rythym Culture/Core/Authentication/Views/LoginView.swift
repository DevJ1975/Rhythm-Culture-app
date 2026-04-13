// LoginView.swift
// Instagram-style login screen with Rhythm Culture branding.

import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) var authViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                // Brand mark
                VStack(spacing: 6) {
                    Text("Rhythm Culture")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("Culture. Media. Community.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .tracking(1.5)
                }
                .padding(.bottom, 48)

                // Input fields
                VStack(spacing: 12) {
                    TextField("Email or username", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 24)

                // Forgot password
                HStack {
                    Spacer()
                    Button("Forgot password?") {}
                        .font(.footnote)
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                // Log in button — bypasses auth until Firebase is connected
                Button {
                    authViewModel.isAuthenticated = true
                } label: {
                    Text("Log in")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // OR divider
                HStack(spacing: 12) {
                    Rectangle().frame(height: 0.5).foregroundStyle(Color(.systemGray3))
                    Text("OR").font(.caption).foregroundStyle(.secondary)
                    Rectangle().frame(height: 0.5).foregroundStyle(Color(.systemGray3))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)

                Spacer()
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Sign up") { showSignUp = true }
                            .font(.subheadline.bold())
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthViewModel())
}
