//
//  XButtonRank.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation

/// Emphasis ranks for `XButton`.
///
/// Use ranks to convey visual hierarchy and emphasis across actions,
/// from most prominent (primary) to least prominent (tertiary).
enum XButtonRank {
    /// Highest emphasis for primary actions.
    case primary
    /// Medium emphasis for supporting actions.
    case secondary
    /// Lowest emphasis for less critical or subtle actions.
    case tertiary
}
