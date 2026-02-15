//
//  RegistrationValidationManager.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/27/25.
//

import Observation

/// Coordinates asynchronous validation of registration inputs and exposes UI-ready state.
///
/// `RegistrationValidationManager` wraps a `RegistrationValidationProtocol` implementation and
/// provides observable properties for email/username validation states and errors. Views can bind
/// to these properties to present validation progress, success, or failure.
///
/// - Note: Marked `@MainActor` because its state is observed by SwiftUI.
@Observable @MainActor
class RegistrationValidationManager {
    /// The current validation state for the email field (idle, validating, validated, invalid).
    var emailValidationState: InputValidationState = .idle
    /// The current validation state for the username field (idle, validating, validated, invalid).
    var usernameValidationState: InputValidationState = .idle
    /// The most recent validation error produced by the underlying service, if any.
    var validationError: RegistrationValidationError?
    
    private let service: RegistrationValidationProtocol
    
    /// Creates a manager with a backend-specific validation service.
    /// - Parameter service: An implementation that performs backend-specific uniqueness checks.
    init(service: RegistrationValidationProtocol) {
        self.service = service
    }
    
    /// Validates the provided email by delegating to the underlying service.
    ///
    /// Sets `emailValidationState` to `.validating` before the request. On success, returns the
    /// resulting state. On failure, captures the error in `validationError` and returns `.invalid`.
    /// - Parameter email: The email address to validate.
    /// - Returns: The resulting validation state.
    func validateEmail(_ email: String) async -> InputValidationState {
        emailValidationState = .validating
        
        do {
            return try await service.validateEmail(email)
        } catch {
            self.validationError = error as? RegistrationValidationError ?? .unknown
            return .invalid
        }
    }
    
    /// Validates the provided username by delegating to the underlying service.
    ///
    /// Sets `usernameValidationState` to `.validating` before the request. On success, returns the
    /// resulting state. On failure, captures the error in `validationError` and returns `.invalid`.
    /// - Parameter username: The username to validate.
    /// - Returns: The resulting validation state.
    func validateUsername(_ username: String) async -> InputValidationState {
        usernameValidationState = .validating
        
        do {
            return try await service.validateUsername(username)
        } catch {
            self.validationError = error as? RegistrationValidationError ?? .unknown
            return .invalid
        }
    }
}

