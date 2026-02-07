//
//  AppleAuthError.swift
//  AuthProPlus
//
//  Created by Assistant on 2/6/26.
//

import Foundation

/// Errors that can occur during Sign in with Apple flows.
///
/// This type provides user-facing descriptions via `LocalizedError` and can be
/// surfaced directly to the UI or used for diagnostics.
enum AppleAuthError: Error, LocalizedError {
    /// The user canceled the Sign in with Apple flow.
    case canceled
    /// The expected Apple ID credential was not provided by the system.
    case credentialMissing
    /// The identity token from Apple was missing or invalid.
    case invalidIdentityToken
    /// The provided nonce was invalid or did not match the expected value.
    case invalidNonce
    /// Exchanging Apple credentials for app credentials failed.
    case tokenExchangeFailed
    /// Authorization failed with an underlying system error.
    case authorizationFailed(underlying: Error)
    /// An unknown error occurred.
    case unknown

    /// A human-readable message describing the error, suitable for display.
    public var errorDescription: String? {
        switch self {
        case .canceled:
            return "Sign in with Apple was canceled."
        case .credentialMissing:
            return "Missing Apple ID credential."
        case .invalidIdentityToken:
            return "Invalid or missing identity token from Apple."
        case .invalidNonce:
            return "Invalid nonce used for Apple sign-in."
        case .tokenExchangeFailed:
            return "Failed to exchange Apple credential for app credentials."
        case .authorizationFailed(let underlying):
            return "Apple authorization failed: \(underlying.localizedDescription)"
        case .unknown:
            return "An unknown error occurred during Apple sign-in."
        }
    }
}
