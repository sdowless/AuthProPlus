//
//  AvatarSize.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/26/25.
//

import Foundation

/// A semantic set of avatar sizes used across the app.
///
/// Use `dimension` to obtain the square size (width and height) in points for a given case.
/// The predefined cases map to common sizes, and `custom(_:)` lets you specify any size.
///
/// Example:
/// ```swift
/// let size: AvatarSize = .small
/// let dimension = size.dimension // 48
/// ```
enum AvatarSize {
    /// A square size of 40×40 points.
    case xSmall
    
    /// A square size of 48×48 points.
    case small
    
    /// A square size of 64×64 points.
    case medium
    
    /// A square size of 80×80 points.
    case large
    
    /// A square size of 100×100 points.
    case xLarge
    
    /// Produces a custom square size (in points).
    case custom(CGFloat)
    
    /// The square dimension in points for this avatar size.
    ///
    /// This value is intended to be used for both width and height when rendering a square avatar.
    /// For example:
    /// ```swift
    /// Image(uiImage: avatar)
    ///     .resizable()
    ///     .frame(width: size.dimension, height: size.dimension)
    ///     .clipShape(Circle())
    /// ```
    var dimension: CGFloat {
        switch self {
        case .xSmall:
            return 40
        case .small:
            return 48
        case .medium:
            return 64
        case .large:
            return 80
        case .xLarge:
            return 100
        case .custom(let size):
            return size
        }
    }
}

