//
//  UserServiceProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import FirebaseAuth
import FirebaseFirestore

/// Default Firestore-backed implementation of `UserServiceProtocol`.
///
/// - Important: This implementation assumes a Firestore collection and a document key
///   matching the Firebase Auth UID. If your app uses a different backend, collection
///   structure, or user schema, create your own implementation that conforms to
///   `UserServiceProtocol` and performs the appropriate mapping from `BaseUser`.
struct FirebaseUserService: UserServiceProtocol {
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
            createdAt: Date()
        )
        
        let encodedUser = try Firestore.Encoder().encode(user)
        try await FirestoreConstants.UserCollection.document(user.id).setData(encodedUser)
    }
}
