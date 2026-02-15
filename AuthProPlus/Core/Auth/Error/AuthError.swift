//
//  AuthFlowError.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation

/// A unified authentication error type that wraps provider-specific errors.
///
/// Use this enum to surface a single error to the UI while preserving
/// provider-level detail for diagnostics and recovery suggestions.
enum AuthError: Error, LocalizedError {
    /// Errors originating from Firebase email/password or general auth operations.
    case firebase(FirebaseAuthError)
    /// Errors specific to Google Sign-In flows.
    case google(GoogleAuthError)
    /// Errors specific to Sign in with Apple flows.
    case apple(AppleAuthError)
    /// Unknow errors
    case unknown(Error)
    
    /// A human-readable description suitable for presenting to end users.
    ///
    /// This delegates to the underlying provider error's `localizedDescription`.
    var errorDescription: String? {
        switch self {
        case .firebase(let err):
            return err.localizedDescription
        case .google(let err):
            return err.localizedDescription
        case .apple(let err):
            return err.localizedDescription
        case .unknown(let err):
            return err.localizedDescription
        }
    }
}

