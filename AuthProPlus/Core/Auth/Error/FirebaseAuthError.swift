//
//  AuthenticationError.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import Foundation

/// A typed representation of Firebase Auth error codes used by the app.
///
/// This enum normalizes Firebase's integer error codes into semantic cases
/// and provides user-facing descriptions via `LocalizedError`.
enum FirebaseAuthError: Error, LocalizedError {
    /// The user's account is disabled.
    case userDisabled
    /// The email address is already associated with another account.
    case emailAlreadyInUse
    /// The email address format is invalid.
    case invalidEmail
    /// The provided password is incorrect.
    case wrongPassword
    /// No user record corresponds to the provided identifier.
    case userNotFound
    /// A network error occurred during the request.
    case networkError
    /// The credential is already associated with a different user account.
    case credentialAlreadyInUse
    /// The password does not meet strength requirements.
    case weakPassword
    /// An unknown or unmapped error occurred.
    case unknown
    /// The provided credential is invalid or malformed.
    case invalidCredential
    /// Too many requests were made in a short period of time.
    case tooManyRequests
    /// The operation requires recent authentication (e.g., deleting the account).
    case requiresRecentLogin

    /// Initializes a `FirebaseAuthError` from an optional Firebase error code.
    ///
    /// - Parameter rawValue: The Firebase Auth error code (e.g., 17009 for wrong password).
    ///   Unknown or missing codes map to `.unknown`.
    init(rawValue: Int?) {
        switch rawValue {
        case 17004: self = .invalidCredential
        case 17005: self = .userDisabled
        case 17007: self = .emailAlreadyInUse
        case 17008: self = .invalidEmail
        case 17009: self = .wrongPassword
        case 17010: self = .tooManyRequests
        case 17011: self = .userNotFound
        case 17014: self = .requiresRecentLogin
        case 17020: self = .networkError
        case 17025: self = .credentialAlreadyInUse
        case 17026: self = .weakPassword
        default: self = .unknown
        }
    }
    
    /// A human-readable message describing the error, suitable for display.
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "The credentials you entered are invalid. Please try again."
        case .userDisabled:
            return "This account has been disabled."
        case .emailAlreadyInUse:
            return "This email is already in use. Please login or try again."
        case .invalidEmail:
            return "The email address entered is invalid. Please try again."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .userNotFound:
            return "There is no account associated with those credentials. Please try again."
        case .networkError:
            return "A network error occurred. Please try again later."
        case .credentialAlreadyInUse:
            return "This credential is already in use. Please try again."
        case .weakPassword:
            return "Password must be at least 6 characters in length. Please try again."
        case .unknown:
            return "An unknown error occurred. Please try again."
        case .tooManyRequests:
            return "Access to this account has been temporarily disabled due to multiple failed login attempts. Please try again later."
        case .requiresRecentLogin:
            return "For your security, please sign in again before performing this action."
        }
    }
}

