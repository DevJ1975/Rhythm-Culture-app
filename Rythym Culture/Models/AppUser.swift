// AppUser.swift
// Core user model. Maps to Firestore `users` collection.

import Foundation

struct AppUser: Identifiable, Codable, Hashable {
    let id: String
    var username: String
    var displayName: String
    var email: String
    var profileImageURL: String?
    var bio: String?
    var artistType: ArtistType?
    var genres: [String]
    var location: String?
    var followersCount: Int
    var followingCount: Int
    var postsCount: Int
    let createdAt: Date

    init(
        id: String,
        username: String,
        displayName: String,
        email: String,
        profileImageURL: String? = nil,
        bio: String? = nil,
        artistType: ArtistType? = nil,
        genres: [String] = [],
        location: String? = nil,
        followersCount: Int = 0,
        followingCount: Int = 0,
        postsCount: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.email = email
        self.profileImageURL = profileImageURL
        self.bio = bio
        self.artistType = artistType
        self.genres = genres
        self.location = location
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.postsCount = postsCount
        self.createdAt = createdAt
    }
}
