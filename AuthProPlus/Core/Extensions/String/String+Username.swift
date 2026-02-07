//
//  String+Username.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

/// Username-related utilities for `String`.
extension String {
    /// Returns true if the string matches the app's username rules.
    ///
    /// Rules:
    /// - 3–20 characters
    /// - Letters, digits, underscore, and dot
    /// - No leading/trailing underscore or dot
    /// - No consecutive underscores or dots
    /// - Returns: `true` if the username is syntactically valid; otherwise, `false`.
    func isValidUsername() -> Bool {
        let usernameRegex = "^(?=.{3,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$"
        
        let userPredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return userPredicate.evaluate(with: self)
    }
}

