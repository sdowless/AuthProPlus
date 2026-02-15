//
//  GoogleAuthService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Firebase
import FirebaseAuth
import Supabase
import GoogleSignIn

/// Default implementation of `GoogleAuthServiceProtocol` backed by Google Sign-In with pluggable backends.
///
/// This service presents the Google Sign-In flow, retrieves the Google ID/access tokens, and then
/// authenticates with the selected backend (Firebase or Supabase). On success, it returns a
/// `GoogleAuthUser` model that you can persist or merge with your app's user record.
///
/// - Configuration:
///   - Firebase: Ensure Firebase is configured and that your `GoogleService-Info.plist` contains
///     a valid `CLIENT_ID` for Google Sign-In.
///   - Supabase: Provide an initialized `SupabaseClient` via `.supabase(client:)` and a Google
///     Sign-In client ID via your config (e.g., `AppConstants.googleClientID`). No Firebase files are required.
///
/// - Usage:
/// ```swift
/// // Firebase backend
/// let firebaseService = GoogleAuthService(provider: .firebase)
///
/// // Supabase backend
/// let supabaseService = GoogleAuthService(provider: .supabase(client: supabaseClient))
/// ```
///
/// - Notes:
///   - When `provider` is `.firebase`, the service exchanges the Google tokens for a Firebase credential
///     and signs in with Firebase Auth.
///   - When `provider` is `.supabase`, the service signs in with Supabase using the Google tokens (no
///     additional OAuth UI required).
struct GoogleAuthService: GoogleAuthServiceProtocol {
    private let provider: AuthServiceProvider
    
    init(provider: AuthServiceProvider) {
        self.provider = provider
    }
    
    /// Initiates Google Sign-In, authenticates with the selected backend, and returns a signed-in user model.
    ///
    /// The method resolves a Google client ID based on `provider`, presents the Google sign-in UI,
    /// retrieves the ID token and access token, and then authenticates with the selected backend.
    ///
    /// - Returns: A `GoogleAuthUser` containing a backend-specific user identifier and Google profile data.
    /// - Throws: `GoogleAuthError` for configuration or token issues, or an error from the selected backend
    ///           if the credential sign-in fails.
    /// - Important: Replace `GoogleAuthUser` with your app's user type if needed, or adapt the
    ///              returned data to your domain model in a higher layer.
    func signIn() async throws -> GoogleAuthUser {
        let clientID = try resolveClientId()
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = scene?.windows.first?.rootViewController else {
            throw GoogleAuthError.noRootViewController
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let googleUser = result.user
    
        guard let idToken = googleUser.idToken?.tokenString else {
            throw GoogleAuthError.invalidToken
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: googleUser.accessToken.tokenString
        )
        
        switch provider {
        case .firebase:
            let firebaseAuthResult = try await Auth.auth().signIn(with: credential)
            
            return GoogleAuthUser(
                id: firebaseAuthResult.user.uid,
                userProfileData: googleUser.profile ?? GIDProfileData()
            )
        case .supabase(let client):
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
    
    /// Resolves the Google Sign-In client ID based on the selected provider.
    /// - Returns: The client ID string used to configure `GIDConfiguration`.
    /// - Throws: `GoogleAuthError.invalidClientID` if no valid client ID can be resolved.
    private func resolveClientId() throws -> String {
        switch provider {
        case .firebase:
            guard let fid = FirebaseApp.app()?.options.clientID else { throw GoogleAuthError.invalidClientID }
            return fid
        case .supabase:
            return AppConstants.googleClientID
        }
    }
}

