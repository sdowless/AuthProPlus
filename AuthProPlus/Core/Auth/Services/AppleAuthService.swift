//
//  AppleAuthService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import AuthenticationServices
import CryptoKit
import Supabase

/// Handles Sign in with Apple authentication and maps results to app models.
///
/// This service exchanges an Apple identity token for Supabase credentials, signs in
/// to Supabase, and constructs an `AppleAuthUser` used by the app. It also provides
/// helpers for generating a cryptographically secure nonce and hashing it with SHA-256.
struct AppleAuthService: AppleAuthServiceProtocol {
    private let client: SupabaseClient
    private let userService: UserServiceProtocol
    
    /// Initializes the AppleAuthService with a Supabase client.
    /// - Parameter client: A configured `SupabaseClient` instance.
    init(client: SupabaseClient) {
        self.client = client
        self.userService = SupabaseUserService(client: client)
    }
    
    /// Exchanges Apple credentials for Supabase credentials and produces an `AppleAuthUser`.
    ///
    /// - Parameters:
    ///   - appleIDCredential: The credential returned by `ASAuthorizationController`.
    ///   - nonce: The original nonce used to create the Apple request (prevents replay attacks).
    /// - Returns: An `AppleAuthUser` with the resolved identity.
    /// - Throws: `AppleAuthError` if token parsing, nonce validation, authorization, or mapping fails.
    ///
    func signInWithApple(_ appleIDCredential: ASAuthorizationAppleIDCredential, nonce: String?) async throws -> AppleAuthUser {
        guard let appleIDToken = appleIDCredential.identityToken else {
            throw AppleAuthError.invalidIdentityToken
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AppleAuthError.invalidIdentityToken
        }
        
        guard let nonce else {
            throw AppleAuthError.invalidNonce
        }
        
        return try await signIn(
            appleIDCredential: appleIDCredential,
            idTokenString: idTokenString,
            nonce: nonce
        )
    }
    
    /// Performs Supabase sign-in using the Apple identity token.
    /// - Parameters:
    ///   - appleIDCredential: The Apple ID credential returned by ASAuthorizationController.
    ///   - idTokenString: The Apple identity token as a UTF-8 string.
    ///   - nonce: The original nonce used in the Apple request.
    /// - Returns: An AppleAuthUser mapped from the Supabase sign-in result.
    private func signIn(
        appleIDCredential: ASAuthorizationAppleIDCredential,
        idTokenString: String,
        nonce: String
    ) async throws -> AppleAuthUser {
        do {
            let supabaseAuthResult = try await client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: idTokenString,
                    accessToken: nil,
                    nonce: nonce
                )
            )
            
            let existingUser = try await userService.fetchUser(withUid: supabaseAuthResult.user.id.uuidString)
            var name: String?
            
            if let nameComponents = appleIDCredential.fullName {
                let formatter = PersonNameComponentsFormatter()
                formatter.style = .medium
                name = formatter.string(from: nameComponents)
            } else {
                name = existingUser?.fullname
            }
            
            return AppleAuthUser(
                id: supabaseAuthResult.user.id.uuidString,
                email: supabaseAuthResult.user.email,
                fullname: name,
                username: existingUser?.username
            )
        } catch {
            throw AppleAuthError.authorizationFailed(underlying: error)
        }
    }
    
    /// Generates a cryptographically secure random string (nonce).
    ///
    /// - Parameter length: Number of characters to generate. Must be greater than 0.
    /// - Returns: A random string consisting of URL-safe characters.
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    /// Computes a SHA-256 hash of the input string.
    ///
    /// - Parameter input: The string to hash.
    /// - Returns: A lowercase hex representation of the SHA-256 hash.
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

