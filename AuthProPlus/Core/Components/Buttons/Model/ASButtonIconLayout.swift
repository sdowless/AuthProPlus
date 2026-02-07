//
//  ASButtonIconLayout.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation

/// Layout options for placing an icon within `ASButton`.
///
/// These options control whether and where an icon appears relative to the button's title.
enum ASButtonIconLayout {
    /// Adds a trailing chevron icon.
    ///
    /// - Important: A chevron will only be added if the button's rank is ``XButtonRank/tertiary``.
    case chevron
    
    /// Places the icon to the left of the button's title.
    case leading
    
    /// Places the icon to the right of the button's title.
    case trailing
}
