//
//  GoogleAuthServiceProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/7/26.
//

import Foundation

/// Abstraction for Google Sign-In operations.
///
/// Implementations handle the Google authentication flow and return a `GoogleAuthUser`
/// representing the signed-in account.
protocol GoogleAuthServiceProtocol {
    /// Initiates the Google Sign-In flow.
    /// - Returns: A `GoogleAuthUser` describing the signed-in account.
    /// - Throws: An error if the sign-in flow fails or is cancelled.
    func signIn() async throws -> GoogleAuthUser
}
