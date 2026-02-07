//
//  String+Email.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

/// Email-related utilities for `String`.
extension String {
    /// Returns true if the string matches a basic email address pattern.
    ///
    /// Uses a regular expression to check for a syntactically valid email address.
    /// This does not verify that the domain exists or that the address can receive mail.
    ///
    /// Example:
    /// ```swift
    /// "user@example.com".isValidEmail() // true
    /// "not-an-email".isValidEmail()     // false
    /// ```
    /// - Returns: `true` if the string matches the email pattern; otherwise, `false`.
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
