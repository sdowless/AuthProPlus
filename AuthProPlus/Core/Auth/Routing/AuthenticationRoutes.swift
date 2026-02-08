//
//  AuthenticationRoutes.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import SwiftUI

/// Top-level routes for the authentication flow.
///
/// Use these with `NavigationStack` and a path binding to drive navigation between
/// login, account creation, and OAuth-specific screens.
enum AuthenticationRoutes: Hashable {
    /// Routes for the login flow (e.g., login screen, password reset).
    case login(LoginRoutes)
    /// Routes for the account creation flow (e.g., user info, password, profile photo).
    case accountCreation(AccountCreationRoutes)
    /// Routes for OAuth-specific onboarding (e.g., username selection after SSO).
    case oAuth(OAuthRoutes)
}

/// Routes for login-related views.
enum LoginRoutes: Int, Hashable {
    /// Primary login screen.
    case loginView
    /// Password reset screen.
    case resetPassword
    
    /// Destination view associated with the route.
    @ViewBuilder
    var destination: some View {
        switch self {
        case .loginView:
            LoginView()
        case .resetPassword:
            PasswordResetView()
        }
    }
}

/// Routes for account creation (sign-up) flow.
enum AccountCreationRoutes: Int, Hashable {
    /// Collects basic user info (email, name, etc.).
    case userInformationView
    /// Creates or confirms a password.
    case passwordView
    /// Selects a profile image.
    case profilePhotoSelectionView
    /// Completion/confirmation screen after successful account creation.
    case completionView
    
    /// Destination view associated with the route.
    @ViewBuilder
    var destination: some View {
        switch self {
        case .userInformationView:
            UserInformationView()
        case .passwordView:
            CreatePasswordView()
        case .profilePhotoSelectionView:
            ProfileImageSelectorView()
        case .completionView:
            AccountCreationCompletionView()
        }
    }
}

/// Routes for OAuth-based onboarding steps.
enum OAuthRoutes: Int, Hashable {
    /// Prompts the user to add a username after OAuth sign-in.
    case usernameView
    
    /// Destination view associated with the route.
    @ViewBuilder
    var destination: some View {
        switch self {
        case .usernameView:
            AddUsernameView()
        }
    }
}
