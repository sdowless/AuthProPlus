//
//  AuthServiceProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation
import FirebaseAuth
import Firebase

/// Default implementation of `AuthServiceProtocol` backed by Firebase Auth.
///
/// This service is responsible for creating accounts, logging in/out, deleting
/// accounts, and reporting the current authentication state using Firebase.
///
/// - Important: Errors thrown by Firebase are mapped to `FirebaseAuthError` where
///   appropriate (e.g., wrong password, user not found). Callers can present
///   `errorDescription` from that type to the user.
struct FirebaseAuthService: AuthServiceProtocol {
    /// Creates a Firebase user and returns an `AuthProPlusUser` model for onboarding.
    ///
    /// - Parameters:
    ///   - email: Email address for the new account.
    ///   - password: Raw password for the new account.
    ///   - username: Desired username/handle for the app.
    ///   - fullname: User's display name, if available.
    /// - Returns: A minimal `AuthProPlusUser` for subsequent persistence.
    /// - Throws: `FirebaseAuthError` if account creation fails.
    func createUser(withEmail email: String, password: String, username: String, fullname: String) async throws -> AuthProPlusUser {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return AuthProPlusUser(
                id: result.user.uid,
                username: username,
                fullname: fullname,
                email: email,
                createdAt: Date()
            )
        } catch {
            throw mapFirebaseAuthError(error)
        }
    }
    
    /// Deletes the currently signed-in Firebase user.
    ///
    /// - Throws: An error if deletion fails. Firebase may require recent login
    ///   for sensitive operations; in that case, callers should prompt the user
    ///   to reauthenticate and try again (see `FirebaseAuthError.requiresRecentLogin`).
    func deleteAccount() async throws {
        try await Auth.auth().currentUser?.delete()
    }
    
    /// Returns the current authentication state based on Firebase's current user.
    func getAuthState() -> AuthenticationState {
        return Auth.auth().currentUser?.uid == nil ? .unauthenticated : .authenticated
    }
    
    /// Attempts to sign in with email and password.
    ///
    /// - Parameters:
    ///   - email: The email address for the account.
    ///   - password: The account password.
    /// - Returns: `.authenticated` on success.
    /// - Throws: `FirebaseAuthError` if sign-in fails.
    func login(withEmail email: String, password: String) async throws -> AuthenticationState {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            return .authenticated
        } catch {
            throw mapFirebaseAuthError(error)
        }
    }
    
    /// Sends a password reset email.
    ///
    /// - Parameter email: The address to send the reset link to.
    /// - Throws: An error if the request fails.
    func sendResetPasswordLink(toEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            print("DEBUG: Failed to send email with error \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Signs out the current Firebase user.
    ///
    /// - Note: This method swallows errors using `try?`. If you need to handle a
    ///   sign-out failure explicitly, consider changing the signature to `throws`.
    func signout() {
        try? Auth.auth().signOut()
    }
    
    /// Maps a raw Firebase Auth `Error` to a strongly typed `FirebaseAuthError`.
    ///
    /// This helper inspects the incoming error as an `NSError` and verifies that it
    /// originates from Firebase Auth (matching `AuthErrorDomain` or the legacy
    /// `"FIRAuthErrorDomain"`). If the error is not from Firebase Auth, it returns
    /// `.unknown`. Otherwise, it converts the Firebase error code (`ns.code`) into
    /// the corresponding `FirebaseAuthError` case.
    ///
    /// - Parameter error: The error thrown by a Firebase Auth operation.
    /// - Returns: A `FirebaseAuthError` representing the specific authentication failure,
    ///            or `.unknown` if the error is not recognized as a Firebase Auth error.
    ///
    /// - Note: Keep `FirebaseAuthError` in sync with Firebase's documented error codes.
    ///         If Firebase introduces new error codes, update the enum to ensure proper
    ///         mapping and avoid falling back to `.unknown`.
    ///
    /// - SeeAlso: `AuthErrorCode` in FirebaseAuth for the authoritative list of error codes.
    private func mapFirebaseAuthError(_ error: Error) -> FirebaseAuthError {
        let ns = error as NSError
        guard ns.domain == AuthErrorDomain || ns.domain == "FIRAuthErrorDomain" else {
            return .unknown
        }
        return FirebaseAuthError(rawValue: ns.code)
    }
}
