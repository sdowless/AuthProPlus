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
    static let projectURLString = "https://xcdbfmblmuszqvtrxsra.supabase.co"
    
    /// Supabase project api key
    static let projectAPIKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjZGJmbWJsbXVzenF2dHJ4c3JhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4NjY1MDgsImV4cCI6MjA3ODQ0MjUwOH0.qdsYN6F-8w1ntULa1iO7CQd-5ftEVn167jabRbGHw20"
}
