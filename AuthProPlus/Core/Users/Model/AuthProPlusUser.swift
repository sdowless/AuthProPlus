//
//  AuthProPlusUser.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation

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
    var username: String?

    /// URL string to the user's profile image.
    var profileImageUrl: String?

    /// Optional display name (e.g., "Jane Appleseed").
    var fullname: String?

    /// Optional email address associated with the account.
    let email: String?

    /// Date when the account was created.
    var createdAt: Date

    /// Last time the user was active (if tracked).
    var lastActiveAt: Date?
}

