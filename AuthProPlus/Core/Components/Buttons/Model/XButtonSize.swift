//
//  XButtonSize.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import Foundation

/// Semantic size options for `XButton`.
///
/// These sizes control the button's height, padding, and possibly font sizing
/// to provide consistent tap targets across the app.
enum XButtonSize {
    /// A smaller height and padding for tighter layouts.
    case compact
    /// The default size offering comfortable tap targets.
    case standard
}
