//
//  SupabaseAuthError.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/13/26.
//

import Foundation
/// Errors that can occur during Supabase authentication flows.
///
/// This enum captures common failure scenarios when using Supabase Auth,
/// whether you're performing email/password operations, password resets,
/// OAuth sign-in (Google/Apple), or admin-protected actions such as deleting users.
///
/// - Note: You can extend this type with additional cases that reflect your
///   app's specific needs or to mirror server-side error codes more directly.
public enum SupabaseAuthError: Error {
    /// The app attempted an operation that requires an authenticated session,
    /// but no user session was found.
    case notAuthenticated

    /// The provided credentials were invalid (e.g., wrong email/password, expired token).
    case invalidCredentials

    /// The app is missing required configuration (e.g., project URL, API key, client IDs).
    case misconfigured

    /// The app could not present or resolve the required UI context (e.g., missing scene/controller).
    case presentationContextUnavailable

    /// The server rejected the request due to insufficient permissions (e.g., admin-only operation).
    case unauthorized

    /// The requested user or resource could not be found.
    case notFound

    /// A network or connectivity issue prevented the request from completing.
    case network

    /// A wrapper for an underlying error surfaced by the Supabase SDK or system.
    case underlying(Error)

    /// A catch-all for unexpected failures.
    case unknown
}

extension SupabaseAuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to perform this action."
        case .invalidCredentials:
            return "The credentials you entered are invalid. Please try again."
        case .misconfigured:
            return "Authentication is not configured correctly. Please contact support."
        case .presentationContextUnavailable:
            return "Unable to present the sign-in flow. Please try again."
        case .unauthorized:
            return "You don’t have permission to perform this action."
        case .notFound:
            return "We couldn’t find the requested account or resource."
        case .network:
            return "A network error occurred. Check your connection and try again."
        case .underlying(let error):
            return error.localizedDescription
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

/// Maps arbitrary errors into `SupabaseAuthError` for consistent handling.
///
/// Use this helper when catching errors from the Supabase SDK to normalize them
/// into cases your UI can present.
public func mapSupabaseAuthError(_ error: Error) -> SupabaseAuthError {
    // Add specific mapping based on known Supabase error types/codes as needed.
    let ns = error as NSError
    // Example heuristic mappings; adjust to your SDK error signatures.
    if ns.domain == NSURLErrorDomain { return .network }

    // Fallback to underlying wrapper so we don’t lose details.
    return .underlying(error)
}

