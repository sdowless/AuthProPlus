//
//  RegistrationValidationProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/14/26.
//


/// A backend-agnostic contract for validating registration inputs.
///
/// Conformers implement backend-specific checks to verify
/// whether inputs like email and username are unique and acceptable for account creation.
protocol RegistrationValidationProtocol {
    /// Validates an email for registration.
    /// - Parameter email: The email address to validate.
    /// - Returns: `.validated` if the email passes uniqueness and format checks; `.invalid` otherwise.
    /// - Throws: A backend-specific `RegistrationValidationError` when the uniqueness check fails or cannot be performed.
    func validateEmail(_ email: String) async throws -> InputValidationState
    
    /// Validates a username for registration.
    /// - Parameter username: The username to validate.
    /// - Returns: `.validated` if the username passes uniqueness and format checks; `.invalid` otherwise.
    /// - Throws: A backend-specific `RegistrationValidationError` when the uniqueness check fails or cannot be performed.
    func validateUsername(_ username: String) async throws -> InputValidationState
}
