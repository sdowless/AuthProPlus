//
//  String+Password.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

/// Password-related utilities for `String`.
extension String {
    /// Returns true if the string meets the minimum password length requirement.
    ///
    /// This check enforces only a minimum character count (currently 6). It does not
    /// enforce complexity rules such as digits, symbols, or mixed case.
    /// - Returns: `true` if the password length is sufficient; otherwise, `false`.
    func isValidPassword() -> Bool {
        return self.count >= 6
    }
}
