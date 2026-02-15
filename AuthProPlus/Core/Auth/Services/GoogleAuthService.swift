//
//  GoogleAuthService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Supabase
import GoogleSignIn

/// Supabase-backed implementation of `GoogleAuthServiceProtocol` using Google Sign-In.
///
/// This service presents the Google Sign-In flow, retrieves the Google ID/access tokens, and then
/// signs in to Supabase using the ID token flow (no secondary OAuth UI). On success, it returns a
/// `GoogleAuthUser` you can persist or merge with your app's user record.
///
/// - Configuration:
///   - Provide a `SupabaseClient` configured for your environment.
///   - Set `AppConstants.googleClientID` to your Google Sign-In client ID.
///   - Ensure your app Info includes the reversed client ID URL scheme for Google redirect.
///   - Enable Google provider in your Supabase project settings.
///
/// - Usage:
/// ```swift
/// let service = GoogleAuthService(client: AppConfig.supabaseClient)
/// let user = try await service.signIn()
/// ```
struct GoogleAuthService: GoogleAuthServiceProtocol {
    /// Supabase client used to perform the token exchange and create a session.
    private let client: SupabaseClient
    
    /// Creates a Google auth service for Supabase.
    /// - Parameter client: A configured `SupabaseClient` instance.
    init(client: SupabaseClient) {
        self.client = client
    }
    
    /// Presents Google Sign-In, exchanges tokens with Supabase, and returns a signed-in user.
    ///
    /// The method configures Google Sign-In with `AppConstants.googleClientID`, presents the sign-in UI,
    /// retrieves the ID token and access token, and calls Supabase `signInWithIdToken` with provider `.google`.
    ///
    /// - Returns: A `GoogleAuthUser` containing the Supabase user ID and Google profile data.
    /// - Throws: `GoogleAuthError.noRootViewController` if presentation fails, `GoogleAuthError.invalidToken`
    ///           if the ID token is missing, or a Supabase auth error if the token exchange fails.
    func signIn() async throws -> GoogleAuthUser {
        let clientID = AppConstants.googleClientID
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootVC = scene?.windows.first?.rootViewController else {
            throw GoogleAuthError.noRootViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        let googleUser = result.user

        guard let idToken = googleUser.idToken?.tokenString else {
            throw GoogleAuthError.invalidToken
        }

        // Sign in to Supabase using the Google tokens (no second OAuth flow)
        let supabaseAuthResult = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .google,
                idToken: idToken,
                accessToken: googleUser.accessToken.tokenString
            )
        )

        return GoogleAuthUser(
            id: supabaseAuthResult.user.id.uuidString,
            userProfileData: googleUser.profile ?? GIDProfileData()
        )
    }
}

