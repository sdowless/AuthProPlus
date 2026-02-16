//
//  ASButtonRank.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

/// Emphasis ranks for `ASButton`.
///
/// Use ranks to convey visual hierarchy and emphasis across actions,
/// from most prominent (primary) to least prominent (tertiary).
enum ASButtonRank {
    /// Highest emphasis for primary actions.
    case primary
    /// Medium emphasis for supporting actions.
    case secondary
    /// Lowest emphasis for less critical or subtle actions.
    case tertiary
}

extension ASButtonRank {
    var loadingIndicatorForegroundStyle: Color {
        switch self {
        case .primary:
            return .primaryTextInverse
        case .secondary, .tertiary:
            return .primaryText
        }
    }
}
