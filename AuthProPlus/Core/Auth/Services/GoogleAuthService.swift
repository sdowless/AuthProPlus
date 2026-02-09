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
/// This service presents the Google Sign-In flow, exchanges the resulting tokens for a Firebase
/// credential, and signs the user into Firebase. On success, it returns a `GoogleAuthUser` model
/// that you can persist or merge with your app's user record.
///
/// - Note: Ensure that Firebase is configured and that your GoogleSignIn client ID is present in
///   your `GoogleService-Info.plist`. Also confirm the reversed client ID URL scheme is added to
///   the app's Info settings so the sign-in redirect can return to your app.
struct GoogleAuthService: GoogleAuthServiceProtocol {
    /// Initiates Google Sign-In, authenticates with Firebase, and returns a signed-in user model.
    ///
    /// The method looks up the configured Google client ID, presents the Google sign-in UI from the
    /// app's root view controller, retrieves the ID token and access token, creates a Firebase
    /// credential, and completes Firebase authentication.
    ///
    /// - Returns: A `GoogleAuthUser` containing the Firebase user ID and Google profile data.
    /// - Throws: `GoogleAuthError` for configuration or token issues, or an error from Firebase Auth
    ///           if the credential sign-in fails.
    /// - Important: Replace `GoogleAuthUser` with your app's user type if needed, or adapt the
    ///              returned data to your domain model in a higher layer.
    func signIn() async throws -> GoogleAuthUser {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw GoogleAuthError.invalidClientID
        }
        
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
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: googleUser.accessToken.tokenString)
        
        let firebaseAuthResult = try await Auth.auth().signIn(with: credential)
        
        return GoogleAuthUser(
            id: firebaseAuthResult.user.uid,
            userProfileData: googleUser.profile ?? GIDProfileData()
        )
    }
}

