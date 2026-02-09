//
//  UserManager.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import FirebaseStorage
import Foundation

/// A main-actor observable object that coordinates user data loading and updates.
///
/// `UserManager` owns the current signed-in user's model, manages loading state,
/// and provides high-level operations to fetch and mutate user profile data via
/// an injected `UserServiceProtocol`.
///
/// - Note: Marked `@MainActor` so UI can safely bind to `currentUser` and `loadingState`.
@MainActor @Observable
final class UserManager {
    /// The currently signed-in user model, or `nil` if not loaded or unauthenticated.
    var currentUser: AuthProPlusUser?
    
    /// The loading state for fetching and preparing user content.
    var loadingState: ContentLoadingState = .loading
    
    /// The backing service that performs network/database operations.
    private let service: UserServiceProtocol
    
    /// Creates a user manager with a given backing service.
    /// - Parameter service: The user service used for persistence and retrieval.
    init(service: UserServiceProtocol) {
        self.service = service
    }
    
    /// Loads the current user's profile from the backing service.
    ///
    /// On success, assigns `currentUser` and sets `loadingState` to `.complete`.
    /// On failure, sets `loadingState` to `.error(error)` and logs a debug message.
    func fetchCurrentUser() async {
        do {
            self.currentUser = try await service.fetchCurrentUser()
            self.loadingState = .complete
        } catch {
            self.loadingState = .error(error)
            print("DEBUG: Error fetching current user: \(error)")
        }
    }
    
    /// Updates the in-memory profile image URL for the current user.
    ///
    /// - Parameter imageURL: The remote URL string for the user's profile image.
    /// - Important: This only mutates local state. Use `uploadProfilePhoto(with:)`
    ///   to upload and persist a new image first.
    func updateProfilePhoto(with imageURL: String) {
        self.currentUser?.profileImageUrl = imageURL
    }
    
    /// Persists a new username and updates local state on success.
    ///
    /// - Parameter username: The new username to set.
    /// - Throws: Any error thrown by the backing service.
    func uploadUsername(_ username: String) async throws {
        try await service.updateUsername(username)
        self.currentUser?.username = username
    }
    
    /// Uploads a new profile photo, updates persistence, and refreshes local state.
    ///
    /// - Parameter imageData: The raw image bytes to upload.
    /// - Throws: Any error thrown by the backing service.
    /// - Postcondition: On success, `currentUser?.profileImageUrl` is updated.
    func uploadProfilePhoto(with imageData: Data) async throws {
        let imageURL = try await service.updateProfilePhoto(imageData)
        updateProfilePhoto(with: imageURL)
    }
    
    /// Persists initial user data after authentication (sign-up or first sign-in).
    ///
    /// - Parameter user: The minimal user data collected during onboarding.
    /// - Note: Errors are logged but not thrown to keep the flow resilient.
    func saveUserDataAfterAuthentication(_ user: any BaseUser) async {
        do {
            try await service.saveUserDataAfterAuthentication(user)
        } catch {
            print("DEBUG: Failed to save user data to firestore with error: \(error)")
        }
    }
}

