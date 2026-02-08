//
//  ASButton.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

/// A configurable button that supports a title, an icon, or both.
///
/// When the environment value `isLoading` is `true`, the button displays a `ProgressView`
/// in place of its content to indicate a pending action.
///
/// You can create buttons with a local image resource, a system symbol name, or just a title.
struct ASButton: View {
    /// Controls loading state; when true, the button shows a progress indicator.
    @Environment(\.isLoading) var isLoading

    /// The optional title text displayed next to the icon.
    private let title: String?
    /// An optional local image asset to use as the button's icon.
    private let imageResource: ImageResource?
    /// An optional SF Symbol name to use as the button's icon.
    private let systemImage: String?
    /// The action to perform when the button is tapped.
    private let action: () -> Void
    
    /// Creates a button with a title and an optional local image resource.
    /// - Parameters:
    ///   - title: The button's title text.
    ///   - imageResource: A local image asset to display as an icon.
    ///   - action: The action to perform when tapped.
    init(_ title: String, imageResource: ImageResource? = nil, action: @escaping () -> Void) {
        self.title = title
        self.imageResource = imageResource
        self.action = action
        self.systemImage = nil
    }
    
    /// Creates a button with a title and a system symbol icon.
    /// - Parameters:
    ///   - title: The button's title text.
    ///   - systemImage: The name of the SF Symbol to display as an icon.
    ///   - action: The action to perform when tapped.
    init(_ title: String, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
        self.imageResource = nil
    }
    
    /// Creates an icon-only button using a system symbol.
    /// - Parameters:
    ///   - systemImage: The name of the SF Symbol to display as the button.
    ///   - action: The action to perform when tapped.
    init(systemImage: String, action: @escaping () -> Void) {
        self.title = nil
        self.imageResource = nil
        
        self.action = action
        self.systemImage = systemImage
    }
    
    /// The content and behavior of the button.
    var body: some View {
        Button { action() } label: {
            HStack(spacing: 6) {
                Group {
                    if isLoading.wrappedValue {
                        ASLoadingIndicator(color: .primaryTextInverse)
                    } else {
                        if let imageResource {
                            Image(imageResource)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                        } else if let systemImage {
                            Image(systemName: systemImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                        }
                        
                        if let title {
                            Text(title)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isLoading = false
    
    ASButton("Next") {
        Task {
            isLoading = true
            try? await Task.sleep(for: .seconds(2))
            isLoading = false
        }
        
    }
    .buttonStyle(.standard, isLoading: $isLoading)
}
