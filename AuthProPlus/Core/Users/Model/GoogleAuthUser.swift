//
//  GoogleAuthUser.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import Foundation
import GoogleSignIn

/// A lightweight user model constructed from Google Sign-In and backend authentication.
///
/// `GoogleAuthUser` conforms to `BaseUser` and exposes commonly used identity fields derived
/// from `GIDProfileData`. Use this model directly or map it to your app's canonical user type
/// after sign-in.
struct GoogleAuthUser: BaseUser {
    /// The backend user identifier returned after signing in with Google credentials.
    let id: String

    /// Raw Google profile data returned by Google Sign-In (name, email, avatar, etc.).
    let userProfileData: GIDProfileData

    /// A username value for your app. Defaults to an empty string; populate this later
    /// during onboarding or by deriving it from Google profile data if appropriate.
    var username: String?

    /// The email address from the Google profile, if available.
    var email: String? { userProfileData.email }

    /// The full name from the Google profile, if available.
    var fullname: String? { userProfileData.name }
}

