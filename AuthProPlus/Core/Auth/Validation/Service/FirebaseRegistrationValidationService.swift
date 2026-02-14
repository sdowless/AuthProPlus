//
//  RegistrationValidationService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation
import Firebase

/// Default Firestore-backed implementation of `RegistrationValidationProtocol`.
///
/// This service checks uniqueness of user inputs by querying the `users` collection in Firestore.
/// It expects a schema where `email` and `username` are stored as fields on the user document.
///
/// - Important: Ensure indexes exist for queries on `email` and `username` for production usage.
/// - Note: Adjust `FirestoreConstants.UserCollection` if your collection path differs.
struct FirebaseRegistrationValidationService: RegistrationValidationProtocol {
    
    /// Checks whether the provided email is unique in Firestore.
    /// - Parameter email: The email address to verify.
    /// - Returns: `.validated` if no conflicting document exists; `.invalid` otherwise.
    /// - Throws: `RegistrationValidationError.emailValidationFailed` if a conflict is found.
    func validateEmail(_ email: String) async throws -> InputValidationState {
        let isValid = try await checkUniqueness(forKey: "email", value: email)
        guard isValid else { throw RegistrationValidationError.emailValidationFailed }
        
        return isValid ? .validated : .invalid
    }
    
    /// Checks whether the provided username is unique in Firestore.
    /// - Parameter username: The username to verify.
    /// - Returns: `.validated` if no conflicting document exists; `.invalid` otherwise.
    /// - Throws: `RegistrationValidationError.usernameValidationFailed` if a conflict is found.
    func validateUsername(_ username: String) async throws -> InputValidationState {
        let isValid = try await checkUniqueness(forKey: "username", value: username)
        guard isValid else { throw RegistrationValidationError.usernameValidationFailed }
        
        return isValid ? .validated : .invalid
    }
    
    /// Queries Firestore for a single document matching the given key/value.
    /// - Parameters:
    ///   - key: The field name to filter on (e.g., "email", "username").
    ///   - value: The value to match.
    /// - Returns: `true` if no document is found, indicating uniqueness; otherwise `false`.
    private func checkUniqueness(forKey key: String, value: String) async throws -> Bool {
        let snapshot = try await FirestoreConstants
            .UserCollection
            .whereField(key, isEqualTo: value)
            .limit(to: 1)
            .getDocuments()
        
        return snapshot.isEmpty
    }
}
