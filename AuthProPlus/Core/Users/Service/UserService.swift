//
//  UserServiceProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import FirebaseAuth
import FirebaseFirestore

/// Defines user-related data operations used by AuthProPlus.
///
/// The default implementation (`UserService`) persists users to Firestore and relies on
/// Firebase Auth for the current user's UID. If your app uses a different backend or
/// user schema, provide your own type conforming to this protocol.
protocol UserServiceProtocol {
    /// Fetches the current authenticated user from the database, if available.
    ///
    /// - Returns: The current `AuthProPlusUser` or `nil` if there is no signed-in user.
    /// - Throws: An error if the fetch operation fails.
    func fetchCurrentUser() async throws -> AuthProPlusUser?

    /// Fetches a user by Firebase Auth UID.
    ///
    /// - Parameter uid: The Firebase Auth UID for the user document.
    /// - Returns: The fetched `AuthProPlusUser`, or `nil` if the document doesn't exist or decoding fails.
    /// - Throws: An error if the fetch operation fails.
    func fetchUser(withUid uid: String) async throws -> AuthProPlusUser?

    /// Updates the current user's username.
    ///
    /// - Parameter username: The new username to persist.
    /// - Throws: An error if the user is not signed in or the update fails.
    func updateUsername(_ username: String) async throws

    /// Uploads and sets the current user's profile photo.
    ///
    /// - Parameter imageData: Raw image data to upload.
    /// - Returns: The URL string of the uploaded image.
    /// - Throws: An error if the user is not signed in, the upload fails, or Firestore update fails.
    func updateProfilePhoto(_ imageData: Data) async throws -> String

    /// Persists base user data after a successful authentication flow.
    ///
    /// Maps a generic `BaseUser` (your app's user type) into an `AuthProPlusUser` for storage.
    ///
    /// - Parameter user: A value conforming to `BaseUser`.
    /// - Throws: An error if encoding or persistence fails.
    func saveUserDataAfterAuthentication(_ user: any BaseUser) async throws
}

/// Default Firestore-backed implementation of `UserServiceProtocol`.
///
/// - Important: This implementation assumes a Firestore collection and a document key
///   matching the Firebase Auth UID. If your app uses a different backend, collection
///   structure, or user schema, create your own implementation that conforms to
///   `UserServiceProtocol` and performs the appropriate mapping from `BaseUser`.
struct UserService: UserServiceProtocol {
    /// Helper responsible for uploading user images and returning a remote URL string.
    private let imageUploader = ImageUploader()
    
    /// Fetches the current authenticated user from Firestore using the Firebase Auth UID.
    func fetchCurrentUser() async throws -> AuthProPlusUser? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
                
        return try await FirestoreConstants
            .UserCollection
            .document(uid)
            .getDocument(as: AuthProPlusUser.self)
    }
    
    /// Fetches a user document by Firebase Auth UID and decodes it as `AuthProPlusUser`.
    func fetchUser(withUid uid: String) async throws -> AuthProPlusUser? {
        return try? await FirestoreConstants
            .UserCollection.document(uid)
            .getDocument(as: AuthProPlusUser.self)
    }
    
    /// Updates the `username` field for the currently authenticated user.
    func updateUsername(_ username: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        try await FirestoreConstants
            .UserCollection.document(uid)
            .updateData(["username": username])
    }
    
    /// Uploads a profile image and updates the current user's `profileImageUrl` in Firestore.
    ///
    /// - Returns: The remote URL string for the uploaded image.
    func updateProfilePhoto(_ imageData: Data) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else { throw FirebaseAuthError.userNotFound }
        let imageUrl = try await imageUploader.uploadImage(imageData: imageData)
        
        try await FirestoreConstants
            .UserCollection.document(uid)
            .updateData(["profileImageUrl": imageUrl])
        
        return imageUrl
    }
    
    /// Persists a minimal user record to Firestore after authentication.
    ///
    /// Maps a generic `BaseUser` (your app-specific user model) to `AuthProPlusUser`.
    /// Customize this mapping to include additional fields as needed.
    func saveUserDataAfterAuthentication(_ baseUser: any BaseUser) async throws {
        let user = AuthProPlusUser(
            id: baseUser.id,
            username: baseUser.username,
            email: baseUser.email,
            isPrivate: false,
            createdAt: Date()
        )
        
        let encodedUser = try Firestore.Encoder().encode(user)
        try await FirestoreConstants.UserCollection.document(user.id).setData(encodedUser)
    }
}
