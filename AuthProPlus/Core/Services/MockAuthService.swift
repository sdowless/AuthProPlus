//
//  MockAuthService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation
import GoogleSignIn

struct MockAuthService: AuthServiceProtocol {
    func uploadUsername(_ username: String) async throws {
        
    }
    
    func createUser(withEmail email: String, password: String, username: String, fullname: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        return MockData.currentUser
    }
    
    func deleteAccount() async throws {
        
    }
    
    func getAuthState() -> AuthenticationState {
        return .unauthenticated
    }
    
    func login(withEmail email: String, password: String) async throws -> AuthenticationState {
        try await Task.sleep(for: .seconds(1))
        return .authenticated
    }
    
    func sendResetPasswordLink(toEmail email: String) async throws {
        
    }
    
    func signout() {
        
    }
}

struct MockGoogleAuthService: GoogleAuthServiceProtocol {
    func signIn() async throws -> XGoogleAuthUser {
        try await Task.sleep(for: .seconds(1))
        return XGoogleAuthUser(id: UUID().uuidString, isNewUser: true, userProfileData: GIDProfileData())
    }
}
