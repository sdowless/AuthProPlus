//
//  LoadingKey.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import SwiftUI

private struct AuthDataStoreKey: EnvironmentKey {
    static let defaultValue: AuthDataStore = AuthDataStore()
}

private struct AuthManagerKey: EnvironmentKey {
    static let provider = AuthConfig.provider

    static var authService: AuthServiceProtocol {
        switch provider {
        case .firebase:
            FirebaseAuthService()
        case .supabase:
            SupabaseAuthService(client: AuthConfig.supabaseClient)
        }
    }
    
    static let defaultValue: AuthManager = AuthManager(
        service: authService,
        googleAuthService: GoogleAuthService(provider: provider),
        appleAuthService: AppleAuthService(provider: provider)
    )
}

private struct RegistrationValidationManagerKey: EnvironmentKey {
    static let provider = AuthConfig.provider

    static var service: RegistrationValidationProtocol {
        switch provider {
        case .firebase:
            FirebaseRegistrationValidationService()
        case .supabase(let client):
            SupabaseRegistrationValidationService(client: client)
        }
    }
    
    static let defaultValue: RegistrationValidationManager = RegistrationValidationManager(service: service)
}

private struct AuthRouterKey: EnvironmentKey {
    static let defaultValue: AuthenticationRouter = AuthenticationRouter()
}

private struct LoadingKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

private struct UserManagerKey: EnvironmentKey {
    static let provider = AuthConfig.provider
    
    static var service: UserServiceProtocol {
        switch provider {
        case .firebase:
            FirebaseUserService()
        case .supabase(client: let client):
            SupabaseUserService(client: client)
        }
    }
    
    static let defaultValue: UserManager = UserManager(service: service)
}

/// Custom environment values used across the authentication flow.
///
/// These values centralize shared state and services (e.g., managers, routers,
/// and loading bindings) so views can access them without manual dependency threading.
extension EnvironmentValues {
    /// A binding that indicates whether an operation is in progress.
    ///
    /// Used by button styles (e.g., `ASButton`'s `.standard`) to show a `ProgressView`
    /// or adjust visual state while actions are running.
    var isLoading: Binding<Bool> {
        get { self[LoadingKey.self] }
        set { self[LoadingKey.self] = newValue }
    }
    
    /// A shared store for authentication form data (email, password, etc.).
    ///
    /// Injected at the root of the authentication flow so child views can bind to fields
    /// without owning their own copies.
    var authDataStore: AuthDataStore {
        get { self[AuthDataStoreKey.self] }
        set { self[AuthDataStoreKey.self] = newValue }
    }
    
    /// The router that controls navigation within the authentication flow.
    ///
    /// Bind this to a `NavigationStack` path and inject it so child views can push routes.
    var authRouter: AuthenticationRouter {
        get { self[AuthRouterKey.self] }
        set { self[AuthRouterKey.self] = newValue }
    }
    
    /// The user manager responsible for user persistence and profile operations.
    var userManager: UserManager {
        get { self[UserManagerKey.self] }
        set { self[UserManagerKey.self] = newValue }
    }
    
    /// The authentication manager responsible for login, signup, and auth state.
    var authManager: AuthManager {
        get { self[AuthManagerKey.self] }
        set { self[AuthManagerKey.self] = newValue }
    }
    
    var registrationValidationManager: RegistrationValidationManager {
        get { self[RegistrationValidationManagerKey.self] }
        set { self[RegistrationValidationManagerKey.self] = newValue }
    }
}
