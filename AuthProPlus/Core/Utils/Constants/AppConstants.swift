//
//  AppConstants.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation

/// Centralized application constants used across AuthProPlus.
///
/// Treat these as sensible defaults. If your app needs environment-specific values
/// or runtime configurability, consider providing an injected configuration object
/// instead of relying on compile-time constants.
struct AppConstants {
    /// Minimum number of characters required for a valid password.
    static let minimumPasswordCount = 6

    /// URL string for Terms of Service.
    ///
    /// - Note: Replace with your app's actual TOS URL. You can also surface this as a
    ///   runtime-configurable setting if different environments require different links.
    static let termsOfServiceURLString = "https://google.com"
    
    /// Supabase project url
    static let projectURLString = "https://nreamagdccsmmiyvtgfh.supabase.co"
    
    /// Supabase project api key
    static let projectAPIKey = "sb_publishable_cpS7PJdot71WHzET9tkKAw_K8_5PatU"
    
    // Supabase google client id
    static let googleClientID = "<your-google-signin-client-id>"
}
