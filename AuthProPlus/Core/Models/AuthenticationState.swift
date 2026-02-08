//
//  AuthenticationState.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation

/// Represents the high-level authentication lifecycle for the app.
///
/// Use this enum to coordinate navigation and feature gating based on whether the
/// user is signed in, signing in, or signed out. Typical usage is to observe this
/// state (e.g., via an observable view model) and switch UI flows accordingly.
///
/// Example:
/// ```swift
/// switch authState {
/// case .notDetermined:
///     ProgressView()
/// case .unauthenticated:
///     AuthRootView()
/// case .authenticating:
///     ProgressView("Signing in…")
/// case .authenticated:
///     MainAppView()
/// }
/// ```
enum AuthenticationState {
    /// Initial state before the app determines whether a previous session exists
    /// (e.g., checking Keychain, secure storage, or refreshing tokens).
    case notDetermined

    /// No valid session is present. Present sign-in / sign-up UI.
    case unauthenticated

    /// A sign-in or token refresh operation is currently in progress.
    case authenticating

    /// The user has a valid session and can access authenticated features.
    case authenticated
}
