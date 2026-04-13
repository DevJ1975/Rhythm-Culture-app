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

                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 24)

            // Creates account and navigates into the app
            Button {
                authViewModel.isAuthenticated = true
            } label: {
                Text("Create Account")
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
