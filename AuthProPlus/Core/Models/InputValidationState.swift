//
//  InputValidationState.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation

/// Represents the state of input validation for a field.
///
/// Use `.idle` before validation begins, `.validating` while an async check is in progress,
/// `.invalid` when the input fails checks, and `.validated` when it passes.
enum InputValidationState {
    /// No validation in progress or not yet started.
    case idle
    /// Validation is in progress (e.g., showing a spinner).
    case validating
    /// The input failed validation (e.g., show error).
    case invalid
    /// The input passed validation.
    case validated
}
