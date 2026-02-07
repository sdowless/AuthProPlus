//
//  String+Name.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation

/// Name-related utilities for `String`.
extension String {
    /// Returns true if the string matches a simple personal-name pattern.
    ///
    /// Allows letters (including many Latin diacritics), spaces, apostrophes, and hyphens.
    /// Disallows digits and most punctuation.
    ///
    /// Examples:
    /// ```swift
    /// "Ana María".isValidName()   // true
    /// "O'Connor".isValidName()    // true
    /// "Jean-Luc".isValidName()    // true
    /// "John3".isValidName()       // false
    /// "Mr. Smith".isValidName()   // false
    /// ```
    /// - Returns: `true` if the string matches the allowed name pattern; otherwise, `false`.
    func isValidName() -> Bool {
        let nameRegex = "^[a-zA-Zà-ÿÀ-Ÿ'\\-\\s]+$"
        
        let namePred = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePred.evaluate(with: self)
    }
}

