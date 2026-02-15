//
//  AuthServiceProvider.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/14/26.
//

import Foundation
import Supabase

/// Selects which backend(s) to authenticate with after Google Sign-In.
enum AuthServiceProvider {
    /// Authenticate only with Firebase using the Google credential.
    case firebase
    /// Authenticate only with Supabase using the Google ID/access tokens.
    case supabase(client: SupabaseClient)
}
