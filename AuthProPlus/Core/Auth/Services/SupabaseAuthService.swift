//
//  SupabaseAuthService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/9/26.
//

import Foundation
import Supabase

/// Supabase-backed implementation of `AuthServiceProtocol`.
///
/// This service wraps common authentication flows (email/password login, sign-up, sign-out,
/// password reset, account deletion, and auth state checks) using a `SupabaseClient`. It exposes
/// a simple interface for the app layer while keeping Supabase-specific details encapsulated.
struct SupabaseAuthService: AuthServiceProtocol {
    /// The `SupabaseClient` instance used to perform all authentication operations.
    private let client: SupabaseClient
    
    /// Initializes the service with a Supabase client configured from `AppConstants`.
    /// - Note: Ensure `AppConstants.projectURLString` and `AppConstants.projectAPIKey` are set
    ///         for the current environment.
    init(client: SupabaseClient) {
        self.client = client
    }
    
    /// Signs in a user with email and password via Supabase Auth.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: `.authenticated` on success.
    /// - Throws: A `SupabaseAuthError` wrapped in your app's error type on failure.
    func login(withEmail email: String, password: String) async throws -> AuthenticationState {
        try await client.auth.signIn(email: email, password: password)
        return .authenticated
    }
    
    /// Signs out the current Supabase session.
    /// - Throws: A `SupabaseAuthError` on failure.
    func signout() async throws {
        try await client.auth.signOut()
    }
    
    /// Deletes the currently authenticated user's account via Supabase Admin API.
    /// - Throws: `AuthError.supabase(.notAuthenticated)` if no user is signed in, or a Supabase error on failure.
    func deleteAccount() async throws {
        guard let user = try? await client.auth.session.user else {
            throw AuthError.supabase(.notAuthenticated)
        }

        try await client.auth.admin.deleteUser(id: user.id)
    }
    
    /// Sends a password reset email using Supabase Auth.
    /// - Parameter email: The email address to send the reset link to.
    /// - Throws: A Supabase-related error if the request fails.
    func sendResetPasswordLink(toEmail email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    /// Returns the current authentication state based on the active Supabase session.
    /// - Returns: `.authenticated` if a session exists; otherwise `.unauthenticated`.
    func getAuthState() async throws -> AuthenticationState {
        let supabaseUser = try? await client.auth.session.user
        return supabaseUser == nil ? .unauthenticated : .authenticated
    }
    
    /// Creates a new user account with email and password and returns an app user model.
    ///
    /// This method performs `auth.signUp` and returns a minimal `AuthProPlusUser` for onboarding.
    /// Persist additional fields to your database as needed.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - username: The desired username.
    ///   - fullname: The user's full name.
    /// - Returns: A minimally populated `AuthProPlusUser`.
    /// - Throws: A Supabase-related error if sign-up fails.
    func createUser(withEmail email: String, password: String, username: String, fullname: String) async throws -> AuthProPlusUser {
        let response = try await client.auth.signUp(email: email, password: password)
        let uid = response.user.id.uuidString

        let user =  AuthProPlusUser(
            id: uid,
            username: username,
            fullname: fullname,
            email: email,
            createdAt: Date()
        )
                
        return user 
    }
}

