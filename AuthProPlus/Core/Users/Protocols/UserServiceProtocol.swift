//
//  UserServiceProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/14/26.
//

import Foundation

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
