// Comment.swift
// Comment on a post. Maps to Firestore `posts/{postId}/comments` subcollection.

import Foundation

struct Comment: Identifiable, Codable {
    let id: String
    let authorId: String
    let authorUsername: String
    let authorImageURL: String
    let text: String
    var likesCount: Int
    var isLikedByCurrentUser: Bool
    let createdAt: Date
}
