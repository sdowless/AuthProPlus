//
//  AppleAuthServiceProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/7/26.
//

import AuthenticationServices
import CryptoKit

/// Abstraction for Sign in with Apple operations.
///
/// Implementations coordinate the Apple authorization flow, generate nonces,
/// and produce an `AppleAuthUser` from the resulting credentials.
protocol AppleAuthServiceProtocol {
    /// Completes the Sign in with Apple flow using the provided credential and nonce.
    /// - Parameters:
    ///   - appleIDCredential: The credential returned by `ASAuthorizationController`.
    ///   - nonce: The raw nonce associated with the request, used for anti-replay protection.
    /// - Returns: An `AppleAuthUser` representing the signed-in account.
    /// - Throws: An error if authorization fails or the credential/nonce is invalid.
    func signInWithApple(_ appleIDCredential: ASAuthorizationAppleIDCredential, nonce: String?) async throws -> AppleAuthUser

    /// Generates a cryptographically secure random nonce string.
    /// - Parameter length: The desired length of the nonce (typically 32).
    /// - Returns: A new random nonce string.
    func randomNonceString(length: Int) -> String

    /// Computes the SHA-256 hash of the input string and returns a hex-encoded digest.
    /// - Parameter input: The input string to hash.
    /// - Returns: A lowercase hex-encoded SHA-256 digest.
    func sha256(_ input: String) -> String
}
