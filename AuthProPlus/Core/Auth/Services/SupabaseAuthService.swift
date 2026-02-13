//
//  SupabaseAuthService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/9/26.
//

import Foundation
import Supabase

struct SupabaseAuthService: AuthServiceProtocol {
    private let client: SupabaseClient
    
    init() {
        self.client = SupabaseClient.init(
            supabaseURL: URL(string: AppConstants.projectURLString)!,
            supabaseKey: AppConstants.projectAPIKey
        )
    }
    
    func login(withEmail email: String, password: String) async throws -> AuthenticationState {
        let _ = try await client.auth.signIn(email: email, password: password)
        return .authenticated
    }
    
    func signout() async throws {
        try await client.auth.signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = try? await client.auth.session.user else {
            throw AuthError.general(.userNotFound)
        }

        try await client.auth.admin.deleteUser(id: user.id)
    }
    
    func sendResetPasswordLink(toEmail email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    func getAuthState() async throws -> AuthenticationState {
        let supabaseUser = try? await client.auth.session.user
        return supabaseUser == nil ? .unauthenticated : .authenticated
    }
    
    func createUser(withEmail email: String, password: String, username: String, fullname: String) async throws -> AuthProPlusUser {
        let response = try await client.auth.signUp(email: email, password: password)
        let uid = response.user.id.uuidString

        let user =  AuthProPlusUser(
            id: uid,
            username: username,
            fullname: fullname,
            email: email,
            isPrivate: false,
            createdAt: Date()
        )
        
        try await client.from("users").insert(user).execute()
        
        return user 
    }
}

