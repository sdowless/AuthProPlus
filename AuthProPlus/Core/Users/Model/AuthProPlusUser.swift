//
//  AuthProPlusUser.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
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
    var username: String { get }
}

extension BaseUser {
    /// Indicates whether a username is required (i.e., currently empty/whitespace only).
    ///
    /// You can use this as a guard to prompt the user to pick a username during onboarding
    /// if your app relies on usernames.
    var requiresUsername: Bool { username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

/// Default user model provided by AuthProPlus for quick starts and demos.
///
/// - Important: This struct is intended as a starting point. Most apps will replace or
///   extend this with their own domain-specific user type while conforming to `BaseUser`.
///   You may safely add/remove fields to align with your backend schema.
///
/// Example of conforming your own user type:
/// ```swift
/// struct MyAppUser: BaseUser, Codable {
///     let id: String
///     var username: String
///     var email: String?
///     var fullname: String?
///     // Add your own fields
///     var avatarURL: URL?
///     var roles: [String]
/// }
/// ```
struct AuthProPlusUser: BaseUser, Codable {
    /// Stable unique identifier for the user.
    let id: String

    /// Public handle or unique name.
    var username: String

    /// URL string to the user's profile image.
    var profileImageUrl: String?

    /// URL string to the user's profile header/cover image.
    var profileHeaderImageUrl: String?

    /// Optional display name (e.g., "Jane Appleseed").
    var fullname: String?

    /// Short user bio or tagline.
    var bio: String?

    /// Optional email address associated with the account.
    let email: String?

    /// Indicates whether the account is private/restricted.
    var isPrivate: Bool

    /// Date when the account was created.
    var createdAt: Date

    /// Last time the user was active (if tracked).
    var lastActiveAt: Date?
}

