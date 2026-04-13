// Post.swift
// Core post model. Maps to Firestore `posts` collection.

import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let authorId: String
    var authorUsername: String
    var authorDisplayName: String
    var authorProfileImageURL: String?
    var authorArtistType: ArtistType?
    var caption: String
    var mediaURLs: [String]
    var mediaType: MediaType
    var postType: PostType
    var genre: String?
    var likesCount: Int
    var commentsCount: Int
    var vibeReactions: VibeReactions
    var isLikedByCurrentUser: Bool
    let createdAt: Date

    enum MediaType: String, Codable {
        case none, image, video
    }

    enum PostType: String, Codable, CaseIterable {
        case standard   // regular post
        case drop       // music / video release
        case battle     // challenge response
        case showcase   // featured performance highlight
        case collab     // open collab request
    }

    struct VibeReactions: Codable {
        var fire: Int = 0
        var move: Int = 0
        var vibes: Int = 0
        var respect: Int = 0

        var total: Int { fire + move + vibes + respect }
    }

    init(
        id: String,
        authorId: String,
        authorUsername: String,
        authorDisplayName: String,
        authorProfileImageURL: String? = nil,
        authorArtistType: ArtistType? = nil,
        caption: String,
        mediaURLs: [String] = [],
        mediaType: MediaType = .none,
        postType: PostType = .standard,
        genre: String? = nil,
        likesCount: Int = 0,
        commentsCount: Int = 0,
        vibeReactions: VibeReactions = VibeReactions(),
        isLikedByCurrentUser: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.authorId = authorId
        self.authorUsername = authorUsername
        self.authorDisplayName = authorDisplayName
        self.authorProfileImageURL = authorProfileImageURL
        self.authorArtistType = authorArtistType
        self.caption = caption
        self.mediaURLs = mediaURLs
        self.mediaType = mediaType
        self.postType = postType
        self.genre = genre
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.vibeReactions = vibeReactions
        self.isLikedByCurrentUser = isLikedByCurrentUser
        self.createdAt = createdAt
    }
}
