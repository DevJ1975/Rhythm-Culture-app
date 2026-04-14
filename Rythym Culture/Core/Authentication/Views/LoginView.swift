// LoginView.swift
// Instagram-style login screen with Rhythm Culture branding.

import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) var authViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    private var canLogin: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && password.count >= 6
    }

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
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .textContentType(.password)
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

                // Error message
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                }

                // Log in button
                Button {
                    Task { await authViewModel.signIn(email: email, password: password) }
                } label: {
                    Group {
                        if authViewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Log in").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.purple, .pink, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .opacity(canLogin ? 1 : 0.5)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .disabled(!canLogin || authViewModel.isLoading)

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
