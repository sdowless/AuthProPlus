//
//  AppConfig.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/14/26.
//

import Supabase
import Foundation

/// Centralized application configuration for authentication backends.
///
/// `AppConfig` provides a single place to construct shared clients and select the
/// active authentication provider (Firebase or Supabase). Update these values per
/// environment (e.g., Debug/Staging/Production) as needed.
///
/// - Note: If you switch to Firebase, ensure `FirebaseApp.configure()` is called at app launch
///   (e.g., in `AuthProPlusApp.init()` when `provider == .firebase`).
struct AppConfig {
    /// A preconfigured `SupabaseClient` for the current environment.
    ///
    /// Uses values from `AppConstants`. Ensure `projectURLString` and `projectAPIKey` are set
    /// correctly for your environment. Do not embed a Supabase service key in client apps; use
    /// the public anon key here and keep admin/service keys on a trusted server.
    static var supabaseClient: SupabaseClient {
        return SupabaseClient(
            supabaseURL: URL(string: AppConstants.projectURLString)!,
            supabaseKey: AppConstants.projectAPIKey
        )
    }
    
    /// Selects the active authentication provider for the app.
    ///
    /// - Usage:
    ///   - Supabase-only:
    ///     ```swift
    ///     .supabase(client: AppConfig.supabaseClient)
    ///     ```
    ///   - Firebase-only:
    ///     ```swift
    ///     .firebase
    ///     ```
    ///
    /// For Supabase-only setups, also provide a Google Sign-In client ID via your config
    /// (e.g., `AppConstants.googleClientID`) used by GoogleAuthService. For Firebase setups,
    /// ensure `GoogleService-Info.plist` and reversed URL scheme are present.
    static var provider: AuthServiceProvider {
        return .supabase(client: supabaseClient)
    }
}

