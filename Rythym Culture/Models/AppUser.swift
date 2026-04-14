// AppUser.swift
// Core user model. Maps to Supabase `profiles` table.

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

    // Maps Swift camelCase properties to Supabase snake_case columns
    enum CodingKeys: String, CodingKey {
        case id, username, email, bio, genres, location
        case displayName    = "display_name"
        case profileImageURL = "profile_image_url"
        case artistType     = "artist_type"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case postsCount     = "posts_count"
        case createdAt      = "created_at"
    }

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
