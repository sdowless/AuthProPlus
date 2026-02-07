//
//  ASAvatarView.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/26/25.
//

import Kingfisher
import SwiftUI

/// A circular avatar view that renders a user's profile image or a provided image at a given size.
///
/// The view prefers the user's remote profile image (if available), otherwise falls back to a provided
/// `Image`, and finally to a system placeholder. The avatar is always rendered as a circle and sized
/// using the provided `AvatarSize`.
///
/// Example:
/// ```swift
/// AvatarView(user: currentUser, size: .small)
/// AvatarView(image: Image("local-avatar"), size: .large)
/// ```
struct ASAvatarView: View {
    /// The user whose profile image URL is used if available.
    private let user: AuthProPlusUser?
    /// An optional local image to display when no remote user image is available.
    private let image: Image?
    /// The semantic avatar size that determines the square dimension.
    private let size: AvatarSize
    
    /// Creates an avatar view that attempts to load the user's remote profile image.
    /// - Parameters:
    ///   - user: The user whose profile image URL will be used if present.
    ///   - size: The semantic size used to determine avatar dimensions.
    init(user: AuthProPlusUser?, size: AvatarSize) {
        self.user = user
        self.size = size
        
        self.image = nil
    }
    
    /// Creates an avatar view with a provided local image.
    /// - Parameters:
    ///   - image: A local image to display when no remote user image is provided.
    ///   - size: The semantic size used to determine avatar dimensions.
    init(image: Image?, size: AvatarSize) {
        self.image = image
        self.size = size
        
        self.user = nil
    }
    
    var body: some View {
        // Display precedence: user remote image > provided local image > system placeholder. Always circular.
        if let imageUrl = user?.profileImageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else if let image = image {
            image
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
                .foregroundStyle(Color(.systemGray5), .gray)
        }
    }
}

#Preview {
    ASAvatarView(user: MockData.currentUser, size: .medium)
}
