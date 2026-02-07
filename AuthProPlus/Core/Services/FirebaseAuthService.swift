//
//  AuthServiceProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation
import FirebaseAuth
import Firebase

struct FirebaseAuthService: AuthServiceProtocol {
    func createUser(withEmail email: String, password: String, username: String, fullname: String) async throws -> User {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return User(
                id: result.user.uid,
                username: username,
                fullname: fullname,
                email: email,
                isPrivate: false,
                createdAt: Date()
            )
        } catch {
            let authErrorCode = AuthErrorCode(_bridgedNSError: error as NSError)?.rawValue
            throw FirebaseAuthError(rawValue: authErrorCode)
        }
    }
    
    func deleteAccount() async throws {
        try await Auth.auth().currentUser?.delete()
    }
    
    func getAuthState() -> AuthenticationState {
        return Auth.auth().currentUser?.uid == nil ? .unauthenticated : .authenticated
    }
    
    func login(withEmail email: String, password: String) async throws -> AuthenticationState {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            return .authenticated
        } catch {
            let authErrorCode = AuthErrorCode(_bridgedNSError: error as NSError)?.rawValue
            throw FirebaseAuthError(rawValue: authErrorCode)
        }
    }
    
    func sendResetPasswordLink(toEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            print("DEBUG: Failed to send email with error \(error.localizedDescription)")
            throw error
        }
    }
    
    func signout() {
        try? Auth.auth().signOut()
    }
}
