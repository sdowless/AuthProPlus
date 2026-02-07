//
//  GoogleAuthService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Firebase
import FirebaseAuth
import GoogleSignIn

struct GoogleAuthService: GoogleAuthServiceProtocol {
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
