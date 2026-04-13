// MainTabView.swift
// Root tab shell — 5 tabs covering the full Rhythm Culture platform.

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, studio, battles, connect, profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(Tab.home)

            StudioView()
                .tabItem {
                    Image(systemName: selectedTab == .studio ? "music.note.house.fill" : "music.note.house")
                    Text("Studio")
                }
                .tag(Tab.studio)

            BattlesView()
                .tabItem {
                    Image(systemName: selectedTab == .battles ? "trophy.fill" : "trophy")
                    Text("Battles")
                }
                .tag(Tab.battles)

            ConnectView()
                .tabItem {
                    Image(systemName: selectedTab == .connect ? "person.2.fill" : "person.2")
                    Text("Connect")
                }
                .tag(Tab.connect)

            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == .profile ? "person.crop.circle.fill" : "person.crop.circle")
                    Text("Profile")
                }
                .tag(Tab.profile)
        }
        .tint(.primary)
    }
}
