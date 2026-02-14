//
//  AuthDataStore.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Observation
import SwiftUI

/// A simple observable data container for authentication and onboarding flows.
///
/// `AuthDataStore` holds transient user inputs (email, username, name, password, and profile image)
/// that are collected across multiple screens during sign-up or sign-in. Views can bind directly to
/// these properties to share state throughout the authentication UI.
@Observable @MainActor
class AuthDataStore {
    /// The user's email address entered during authentication.
    var email = ""
    /// The username the user would like to claim.
    var username = ""
    /// The user's display name or full name.
    var name = ""
    /// The user's password for email/password sign-up or login.
    var password = ""
    /// An optional profile image selected during onboarding.
    var profileImage: Image?
}
