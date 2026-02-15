//
//  StandardButtonLabelStyle.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/15/26.
//

import SwiftUI

struct StandardButtonLabelStyle: LabelStyle {
    @Environment(\.isLoading) var isLoading
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var rank: ASButtonRank
    private var size: ASButtonSize
    private var variant: ASButtonVariant
    private var iconLayout: ASButtonIconLayout
    private var isPressed: Bool
    private var fillWidth: Bool
    
    init(
        rank: ASButtonRank,
        size: ASButtonSize = .standard,
        variant: ASButtonVariant = .primary,
        iconLayout: ASButtonIconLayout = .leading,
        isPressed: Bool = false,
        fillWidth: Bool = false
    ) {
        self.rank = rank
        self.size = size
        self.variant = variant
        self.iconLayout = iconLayout
        self.isPressed = isPressed
        self.fillWidth = fillWidth
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            if isLoading.wrappedValue {
                ASLoadingIndicator(color: rank.loadingIndicatorForegroundStyle)
            } else {
                Group {
                    switch iconLayout {
                    case .chevron:
                        HStack(spacing: 6) {
                            configuration.title
                            
                            Image(systemName: "chevron.right")
                                .imageScale(.small)
                        }
                        .padding(.horizontal, 8)
                    case .leading:
                        HStack(spacing: 6) {
                            configuration.icon
                            
                            configuration.title
                        }
                        .padding(.horizontal, 8)
                    case .trailing:
                        HStack(spacing: 6) {
                            configuration.title
                            
                            configuration.icon
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .font(size == .compact ? .subheadline : .headline)
                .fontWeight(.semibold)
            }
        }
        .frame(width: width, height: height)
        .frame(maxWidth: fillWidth ? .infinity : nil)
        .foregroundStyle(foregroundColor.opacity(isPressed ? 0.4 : 1.0))
        .background(backgroundColor.opacity(isPressed ? 0.4 : 1.0))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay {
            Capsule()
                .stroke(borderColor, lineWidth: 1.0)
                .opacity(isPressed ? 0.4 : 1.0)
        }
    }
}

extension LabelStyle where Self == StandardButtonLabelStyle {
    static func standardButton(
        rank: ASButtonRank = .primary,
        size: ASButtonSize = .standard,
        variant: ASButtonVariant = .primary,
        iconLayout: ASButtonIconLayout = .leading,
        isPressed: Bool = false,
        fillWidth: Bool = false
    ) -> Self {
        return StandardButtonLabelStyle(
            rank: rank,
            size: size,
            variant: variant,
            iconLayout: iconLayout,
            isPressed: isPressed,
            fillWidth: fillWidth
        )
    }
}

private extension StandardButtonLabelStyle {
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
