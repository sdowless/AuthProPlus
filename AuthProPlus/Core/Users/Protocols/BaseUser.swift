//
//  BaseUser.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/14/26.
//

import Foundation

/// A minimal, app-agnostic user contract used by AuthProPlus.
///
/// Conform your app's user type to `BaseUser` so it can interoperate with
/// AuthProPlus components (e.g., profile, mentions, ownership checks).
/// Only the required identity fields are prescribed; you are expected to
/// extend your concrete user model with any domain-specific properties.
///
/// Required properties:
/// - `id`: Stable unique identifier for the user (string-typed for flexibility).
/// - `email`: Optional email address, if available.
/// - `fullname`: Optional display name.
/// - `username`: Public handle or unique name. Can be empty if your app doesn't use usernames.
protocol BaseUser: Identifiable, Hashable {
    /// Stable unique identifier for the user.
    var id: String { get }

    /// Optional email address associated with the account.
    var email: String? { get }

    /// Optional display name (e.g., "Jane Appleseed").
    var fullname: String? { get }

    /// Public handle or unique name. May be empty if your app doesn't require usernames.
    var username: String? { get }
}

extension BaseUser {
    /// Indicates whether a username is required (i.e., currently empty/whitespace only).
    ///
    /// You can use this as a guard to prompt the user to pick a username during onboarding
    /// if your app relies on usernames.
    var requiresUsername: Bool {
        if let username {
            return username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } else {
            return true
        }
    }
}
