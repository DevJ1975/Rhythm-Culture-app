// ConnectView.swift
// Connect tab — Collabs + Auditions in one place.

import SwiftUI

struct ConnectView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Connect", selection: $selectedTab) {
                    Text("Collabs").tag(0)
                    Text("Auditions").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                Divider()

                if selectedTab == 0 {
                    CollabBoardView()
                } else {
                    AuditionsView()
                }
            }
            .navigationTitle("Connect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: { Image(systemName: "plus").foregroundStyle(.primary) }
                }
            }
        }
    }
}
