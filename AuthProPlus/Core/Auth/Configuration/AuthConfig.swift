//
//  AuthConfig.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/14/26.
//

import Supabase
import Foundation

/// Centralized application configuration for authentication.
///
/// `AuthConfig` provides a single place to construct shared clients and select the
/// active authentication setup for the current environment (e.g., Debug/Staging/Production).
struct AuthConfig {
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
}

