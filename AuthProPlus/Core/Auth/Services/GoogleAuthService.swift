//
//  GoogleAuthService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Firebase
import FirebaseAuth
import GoogleSignIn

/// Default implementation of `GoogleAuthServiceProtocol` backed by Google Sign-In and Firebase Auth.
///
/// This service presents the Google Sign-In flow, retrieves the Google ID/access tokens, and then
/// exchanges them for a Firebase credential to sign the user in. On success, it returns a
/// `GoogleAuthUser` model that you can persist or merge with your app's user record.
///
/// - Configuration:
///   - Ensure Firebase is configured and that your `GoogleService-Info.plist` contains
///     a valid `CLIENT_ID` for Google Sign-In.
///   - Confirm the reversed client ID URL scheme is added to the app's Info settings so the
///     sign-in redirect can return to your app.
///
/// - Usage:
/// ```swift
/// let service = GoogleAuthService()
/// let user = try await service.signIn()
/// ```
struct GoogleAuthService: GoogleAuthServiceProtocol {
    /// Initiates Google Sign-In, authenticates with Firebase, and returns a signed-in user model.
    ///
    /// The method resolves a Google client ID from Firebase configuration, presents the Google sign-in UI,
    /// retrieves the ID token and access token, and then authenticates with Firebase using a Google credential.
    ///
    /// - Returns: A `GoogleAuthUser` containing the Firebase user identifier and Google profile data.
    /// - Throws: `GoogleAuthError` for configuration or token issues, or an error from Firebase Auth
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
        
        let firebaseAuthResult = try await Auth.auth().signIn(with: credential)
        
        return GoogleAuthUser(
            id: firebaseAuthResult.user.uid,
            userProfileData: googleUser.profile ?? GIDProfileData()
        )
    }
    
    /// Resolves the Google Sign-In client ID from Firebase configuration.
    /// - Returns: The client ID string used to configure `GIDConfiguration`.
    /// - Throws: `GoogleAuthError.invalidClientID` if no valid client ID can be resolved.
    private func resolveClientId() throws -> String {
        guard let fid = FirebaseApp.app()?.options.clientID else { throw GoogleAuthError.invalidClientID }
        return fid
    }
}

