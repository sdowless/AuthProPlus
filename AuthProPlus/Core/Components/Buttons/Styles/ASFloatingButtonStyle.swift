//
//  ASFloatingButtonStyle.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/11/25.
//

import SwiftUI

/// A circular floating button style with a branded background and drop shadow.
///
/// Applies a large icon scale, white foreground, and a circular primary-blue background
/// with a subtle shadow. Intended for prominent actions that float above content.
struct ASFloatingButtonStyle: ButtonStyle {
    /// Creates the styled button body for the given configuration.
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .imageScale(.large)
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background {
                Circle()
                    .fill(.primaryBlue)
                    .frame(width: 54, height: 54)
                    .shadow(color: .primary.opacity(0.25), radius: 6)
            }
            .padding()
    }
}

/// Convenience API for applying the floating button style.
///
/// Example:
/// ```swift
/// Button(action: createPost) {
///     Image(systemName: "plus")
/// }
/// .buttonStyle(.floating)
/// ```
extension ButtonStyle where Self == ASFloatingButtonStyle {
    /// A convenience static value to apply `XFloatingButtonStyle` using `.buttonStyle(.floating)`.
    static var floating: ASFloatingButtonStyle {
        .init()
    }
}
