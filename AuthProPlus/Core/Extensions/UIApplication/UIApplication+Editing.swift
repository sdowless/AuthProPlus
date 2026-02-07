//
//  UIApplication+Editing.swift
//  XClone
//
//  Created by Stephan Dowless on 2/11/25.
//

import UIKit

/// Utilities for managing editing state in UIKit.
extension UIApplication {
    /// Ends editing in the current application by asking the first responder to resign.
    ///
    /// This is useful for dismissing the keyboard from SwiftUI or UIKit contexts
    /// when you don't have a direct reference to the current first responder.
    ///
    /// Example (SwiftUI):
    /// ```swift
    /// UIApplication.shared.endEditing()
    /// ```
    ///
    /// - Note: This sends the `resignFirstResponder` action to `nil`, allowing UIKit
    ///   to route it to the current first responder.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

