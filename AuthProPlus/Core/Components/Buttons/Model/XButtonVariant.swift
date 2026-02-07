//
//  XButtonVariant.swift
//  XClone
//
//  Created by Stephan Dowless on 1/30/25.
//

import Foundation

/// Visual styling variants for `XButton`.
///
/// Use these variants to apply a consistent background and foreground treatment
/// across the app's buttons.
enum XButtonVariant {
    /// Uses the app's primary brand color as the background; foreground adapts for contrast.
    case primary
    
    /// Uses a system background treatment appropriate for the current appearance.
    case system
}
