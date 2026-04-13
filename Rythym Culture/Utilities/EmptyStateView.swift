// EmptyStateView.swift
// Reusable empty / zero-state component used across feeds and lists.

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(.secondary.opacity(0.5))

            VStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let label = actionLabel, let action {
                Button(action: action) {
                    Text(label)
                        .font(.subheadline.bold())
                        .padding(.horizontal, 24).padding(.vertical, 10)
                        .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}
