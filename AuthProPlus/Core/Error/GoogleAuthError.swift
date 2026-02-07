//
//  GoogleAuthError.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import Foundation

/// Errors that can occur during Google Sign-In flows.
///
/// Provides user-facing descriptions via `LocalizedError` and can be surfaced
/// directly to the UI or used for diagnostics.
enum GoogleAuthError: Error, LocalizedError {
    /// The Google Client ID is missing or misconfigured.
    case invalidClientID
    /// No suitable root view controller was available to present the sign-in UI.
    case noRootViewController
    /// The Google ID token was missing, expired, or invalid.
    case invalidToken
    /// Required profile information could not be retrieved from Google.
    case invalidProfileData
    /// An unknown error occurred.
    case unknown
    
    /// A human-readable message describing the error, suitable for display.
    var errorDescription: String? {
        switch self {
        case .invalidClientID:
            return "Google Sign-In is misconfigured. Please verify the Client ID."
        case .noRootViewController:
            return "Unable to present Google Sign-In. No root view controller available."
        case .invalidToken:
            return "We couldn't verify your Google account token. Please try again."
        case .invalidProfileData:
            return "We couldn't retrieve your Google profile information."
        case .unknown:
            return "An unknown error occurred during Google Sign-In. Please try again."
        }
    }
}

