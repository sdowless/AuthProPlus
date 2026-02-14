//
//  AppleAuthUser.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import Foundation

/// A lightweight user model produced from Sign in with Apple and Firebase authentication.
///
/// `AppleAuthUser` conforms to `BaseUser` and carries the identifiers and profile data available
/// from Apple's sign-in flow. Use this model directly or map it to your app's canonical user type
/// after authentication.
///
/// - Note: Depending on the user's choices and Apple's policies, email and full name may only be
///   provided on the very first authorization. Persist these values if you need them later.
/// - SeeAlso: `ASAuthorizationAppleIDCredential` for details on the available fields.
struct AppleAuthUser: BaseUser {
    /// The stable identifier (e.g., Firebase UID or app-scoped Apple identifier) for the user.
    let id: String
    
    /// The email address provided by Sign in with Apple, if available.
    let email: String?
    
    /// The user's full name provided by Sign in with Apple, if available.
    let fullname: String?
    
    /// A username value for your app. Defaults to an empty string; populate during onboarding
    /// or derive it from other profile information as needed.
    var username: String?
}

