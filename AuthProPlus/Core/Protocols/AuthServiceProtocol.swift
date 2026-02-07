//
//  AuthServiceProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation

/// Abstraction for authentication-related operations.
///
/// Concrete implementations (e.g., Firebase-backed services) provide user creation,
/// login, password reset, and account management. The protocol is designed for use
/// with async/await and to support dependency injection in the UI layer.
protocol AuthServiceProtocol {
    /// Creates a new user account.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - username: The chosen username.
    ///   - fullname: The user's full name.
    /// - Returns: The created `User` model.
    /// - Throws: An error if user creation fails.
    func createUser(withEmail email: String, password: String, username: String, fullname: String) async throws -> User
    
    /// Deletes the current user's account.
    /// - Throws: An error if the account cannot be deleted.
    func deleteAccount() async throws
    
    /// Returns the current authentication state.
    ///
    /// Implementations may consult cached credentials or underlying SDKs.
    func getAuthState() -> AuthenticationState
    
    /// Signs in using an email and password.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: The resulting `AuthenticationState` after login.
    /// - Throws: An error if sign-in fails.
    func login(withEmail email: String, password: String) async throws -> AuthenticationState
    
    /// Sends a password reset link to the specified email address.
    /// - Parameter email: The email address to receive the reset link.
    /// - Throws: An error if the request fails.
    func sendResetPasswordLink(toEmail email: String) async throws
    
    /// Signs out the current user and clears any persisted session state.
    func signout()
}
