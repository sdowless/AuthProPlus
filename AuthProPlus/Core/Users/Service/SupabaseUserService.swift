//
//  SupabaseUserService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on Valentines Day <3 2/14/26.
//

import Foundation
import Supabase
/// Default Supabase-backed implementation of `UserServiceProtocol`.
///
/// - Important: This implementation assumes a Supabase table named `users` with a primary key
///   matching the app user id and columns that map to `AuthProPlusUser`.
///   Adjust table/column names to match your schema.
struct SupabaseUserService: UserServiceProtocol {
    private let client: SupabaseClient
    private let imageUploader: ImageUploader

    init(client: SupabaseClient) {
        self.client = client
        self.imageUploader = ImageUploader(client: client)
    }

    /// Fetches the current authenticated user from Supabase using the auth session.
    func fetchCurrentUser() async throws -> AuthProPlusUser? {
        let session = try await client.auth.session
        guard let uid = session.user.id.uuidString as String? else { return nil }
        return try await fetchUser(withUid: uid)
    }

    /// Fetches a user row by id and decodes it as `AuthProPlusUser`.
    func fetchUser(withUid uid: String) async throws -> AuthProPlusUser? {
        // Adjust table and column names to your schema.
        let response: [AuthProPlusUser] = try await client
            .from("users")
            .select()
            .eq("id", value: uid)
            .limit(1)
            .execute()
            .value
        
        return response.first
    }

    /// Updates the `username` field for the current authenticated user.
    func updateUsername(_ username: String) async throws {
        let session = try await client.auth.session
        let uid = session.user.id.uuidString
        
        try await client
            .from("users")
            .update(["username": username])
            .eq("id", value: uid)
            .execute()
    }

    /// Uploads a profile image and updates the current user's `profileImageUrl` in Supabase.
    ///
    /// - Returns: The remote URL string for the uploaded image.
    func updateProfilePhoto(_ imageData: Data) async throws -> String {
        let bucket = client.storage.from("profile-photos")
        let filePath = "\(UUID().uuidString).jpg"
        try await bucket.upload(filePath, data: imageData, options: .init(contentType: "image/jpeg", upsert: true))
        let publicURL = try bucket.getPublicURL(path: filePath)

        let session = try await client.auth.session
        let uid = session.user.id.uuidString
        try await client
            .from("users")
            .update(["profileImageUrl": publicURL.absoluteString])
            .eq("id", value: uid)
            .execute()
        
        return publicURL.absoluteString
    }

    /// Persists a minimal user record to Supabase after authentication.
    ///
    /// Maps a generic `BaseUser` (your app-specific user model) to `AuthProPlusUser` and inserts/upserts it.
    func saveUserDataAfterAuthentication(_ baseUser: any BaseUser) async throws {
        let user = AuthProPlusUser(
            id: baseUser.id,
            username: baseUser.username,
            email: baseUser.email,
            createdAt: Date()
        )
        // Upsert into `users` table (adjust table/columns to match your schema).
        try await client
            .from("users")
            .insert(user)
            .execute()
    }
}

