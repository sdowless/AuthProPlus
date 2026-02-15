//
//  View+ButtonStyle.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import SwiftUI

/// Convenience APIs for applying button styles with a loading state.
///
/// These helpers apply a given `ButtonStyle` and inject an `isLoading` binding
/// into the environment so styled buttons can react (e.g., show a spinner).
extension View {
    /// Applies a button style and publishes a loading state to the environment.
    ///
    /// Use this overload when your button style needs to react to a loading state,
    /// such as showing a `ProgressView` while an action is in progress.
    /// - Parameters:
    ///   - style: The `ButtonStyle` to apply.
    ///   - isLoading: A binding indicating whether the button should display a loading state.
    /// - Returns: A view that applies `style` and sets the `isLoading` environment value.
    ///
    /// Example:
    /// ```swift
    /// ASButton("Login") { login() }
    ///     .buttonStyle(.standard, isLoading: $isAuthenticating)
    /// ```
    func buttonStyle<S: ButtonStyle>(_ style: S, isLoading: Binding<Bool>) -> some View {
        self.buttonStyle(style)
            .environment(\.isLoading, isLoading)
    }
}

extension View {
    func labelStyle<S: LabelStyle>(_ style: S, isLoading: Binding<Bool>) -> some View {
        self.labelStyle(style)
            .environment(\.isLoading, isLoading)
    }
}
