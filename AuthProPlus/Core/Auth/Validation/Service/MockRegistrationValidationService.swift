//
//  MockRegistrationValidationService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/14/26.
//

import Foundation

// Mock implementation of `RegistrationValidationProtocol` for testing and previews.
///
/// This mock performs only local format checks and does not query any backend.
struct MockRegistrationValidationService: RegistrationValidationProtocol {
    /// Returns `.validated` when `email.isValidEmail()` is true; `.invalid` otherwise.
    func validateEmail(_ email: String) async throws -> InputValidationState {
        return email.isValidEmail() ? .validated : .invalid
    }
    
    /// Returns `.validated` when `username.isValidUsername()` is true; `.invalid` otherwise.
    func validateUsername(_ username: String) async throws -> InputValidationState {
        return username.isValidUsername() ? .validated : .invalid
    }
}
