// SignUpView.swift
// New account registration screen.

import SwiftUI

struct SignUpView: View {
    @Environment(AuthViewModel.self) var authViewModel
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var password = ""

    private var canSubmit: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        password.count >= 6
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Create Account")
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 32)

            VStack(spacing: 12) {
                TextField("Full name", text: $displayName)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .textContentType(.name)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.username)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)

                SecureField("Password (min 6 characters)", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .textContentType(.newPassword)
            }
            .padding(.horizontal, 24)

            // Error / info message
            if let message = authViewModel.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(message.contains("email") ? .orange : .red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
            }

            Button {
                Task {
                    await authViewModel.signUp(
                        email: email,
                        password: password,
                        username: username,
                        displayName: displayName
                    )
                }
            } label: {
                Group {
                    if authViewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Create Account").fontWeight(.semibold)
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
                    .opacity(canSubmit ? 1 : 0.5)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .disabled(!canSubmit || authViewModel.isLoading)

            Spacer()
        }
        .navigationTitle("")
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environment(AuthViewModel())
    }
}
