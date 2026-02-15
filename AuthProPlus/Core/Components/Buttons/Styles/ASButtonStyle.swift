//
//  ASButtonStyle.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

/// A configurable capsule-style button appearance used across the app.
///
/// The style supports semantic rank, size, icon layout, and variant options to create
/// consistent button appearances for primary, secondary, and tertiary actions.
struct ASButtonStyle: ButtonStyle {
    /// The current color scheme, used to adapt border contrast.
    @Environment(\.colorScheme) var colorScheme
    /// The loading state of the button
    @Environment(\.isLoading) var isLoading
    
    /// Emphasis rank that controls foreground, background, and border treatment.
    private var rank: ASButtonRank
    /// Size semantics that control height, width, padding, and typography.
    private var size: ASButtonSize
    /// Icon placement relative to the title (if present).
    private var iconLayout: ASButtonIconLayout
    /// Visual variant that selects between system and branded backgrounds.
    private var variant: ASButtonVariant = .system
    
    /// Creates a standard button style.
    /// - Parameters:
    ///   - rank: The emphasis rank (primary, secondary, tertiary).
    ///   - size: The size semantics (compact, standard).
    ///   - iconLayout: The icon placement relative to the title.
    ///   - variant: The visual variant (system or primary).
    init(rank: ASButtonRank, size: ASButtonSize, iconLayout: ASButtonIconLayout, variant: ASButtonVariant) {
        self.rank = rank
        self.size = size
        self.iconLayout = iconLayout
        self.variant = variant
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .labelStyle(
                .standardButton(
                    rank: rank,
                    size: size,
                    variant: variant,
                    iconLayout: iconLayout,
                    isPressed: configuration.isPressed
                ),
                isLoading: isLoading
            )
    }
}

private extension ASButtonStyle {
    /// The background color resolved from the current variant and rank.
    var backgroundColor: Color {
        switch variant {
        case .primary: .primaryText
        case .system:
            switch rank {
            case .primary: .primaryText
            case .secondary: Color(.systemBackground)
            case .tertiary: .clear
            }
        }
    }
    
    /// The border stroke color; typically clear for branded variant.
    var borderColor: Color {
        guard variant == .system else { return .clear }
        
        switch rank {
        case .primary, .tertiary:
            return .clear
        case .secondary:
            return .gray
        }
    }
    
    /// The foreground (text/icon) color resolved from variant and rank.
    var foregroundColor: Color {
        switch variant {
        case .primary:
            return .primaryText
        case .system:
            switch rank {
            case .primary:
                return .primaryTextInverse
            case .secondary, .tertiary:
                return Color(.primaryText)
            }
        }
    }
    
    /// The fixed width for certain combinations; nil means size to fit.
    var width: CGFloat? {
        switch size {
        case .compact:
            return nil
        case .standard:
            switch rank {
            case .primary, .secondary:
                return 360
            case .tertiary:
                return nil
            }
        }
    }
    
    /// The fixed height for certain combinations; nil means size to fit.
    var height: CGFloat? {
        switch size {
        case .compact:
            return 34
        case .standard:
            switch rank {
            case .primary, .secondary:
                return 50
            case .tertiary:
                return nil
            }
        }
    }
}

extension ButtonStyle where Self == ASButtonStyle {
    /// The default standard button style (primary rank, standard size, leading icon, system variant).
    static var standard: ASButtonStyle {
        return ASButtonStyle(
            rank: .primary,
            size: .standard,
            iconLayout: .leading,
            variant: .system
        )
    }
    
    /// Creates a standard button style with configurable parameters.
    /// - Parameters:
    ///   - rank: The emphasis rank. Defaults to `.primary`.
    ///   - size: The size semantics. Defaults to `.standard`.
    ///   - iconLayout: The icon placement. Defaults to `.leading`.
    ///   - variant: The visual variant. Defaults to `.system`.
    static func standard(
        rank: ASButtonRank = .primary,
        size: ASButtonSize = .standard,
        iconLayout: ASButtonIconLayout = .leading,
        variant: ASButtonVariant = .system
    ) -> Self {
        .init(rank: rank, size: size, iconLayout: iconLayout, variant: variant)
    }
}
