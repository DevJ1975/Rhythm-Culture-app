// StoryItem.swift
// View-layer model for story bubbles in the feed header.

import SwiftUI

struct StoryItem: Identifiable {
    let id: String
    let username: String
    let gradientColors: [Color]
    var imageURL: String? = nil
    var isSelf: Bool = false
    var hasUnseenStory: Bool = true
}
