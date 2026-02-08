//
//  ASTextField.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import SwiftUI

/// A reusable text input field with optional validation UI.
///
/// Supports secure text entry, a floating title label, and inline validation feedback
/// via `InputValidationState` (progress, invalid, validated) and an optional error message.
struct ASTextField: View {
    @Binding private var text: String
    
    private let titleKey: String
    private let title: String
    private let validationState: InputValidationState
    private let errorMessage: String?
    private let isSecureField: Bool
    
    /// Creates a form input field.
    /// - Parameters:
    ///   - titleKey: The placeholder for the text field
    ///   - title: The floating title above the text field
    ///   - validationState: The validation state that controls inline indicators. Defaults to `.idle`.
    ///   - errorMessage: An optional error message displayed when the state is `.invalid`.
    ///   - isSecureField: Whether to obscure input (secure entry). Defaults to `false`.
    ///   - text: A binding to the text value.
    init(
        _ titleKey: String,
        title: String,
        validationState: InputValidationState = .idle,
        errorMessage: String? = nil,
        isSecureField: Bool = false,
        text: Binding<String>
    ) {
        _text = text
        
        self.titleKey = titleKey
        self.title = title
        self.validationState = validationState
        self.errorMessage = errorMessage
        self.isSecureField = isSecureField
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundStyle(.primary.opacity(0.87))
                .font(.footnote)
            
            Group {
                if isSecureField {
                    SecureField(titleKey, text: $text)
                        .font(.subheadline)
                        .padding(12)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    TextField(titleKey, text: $text)
                        .font(.subheadline)
                        .padding(12)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .font(.subheadline)
            .background(
                Color(.systemGray6)
                    .overlay(alignment: .trailing) {
                        Group {
                            switch validationState {
                            case .idle:
                                EmptyView()
                            case .validating:
                                ProgressView()
                            case .invalid:
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                            case .validated:
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(.trailing, 12)
                    }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(width: 360)
            
            if validationState == .invalid, let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ASTextField("name@example.com", title: "Email", text: .constant(""))
        ASTextField("name@example.com", title: "Email", validationState: .validating, text: .constant(""))
        ASTextField("name@example.com", title: "Email", validationState: .invalid, text: .constant(""))
        ASTextField("name@example.com", title: "Email", validationState: .validated, text: .constant(""))
        
        ASTextField(
            "name@example.com",
            title: "Email",
            validationState: .invalid,
            errorMessage: "An error ocurred. Please try again.",
            text: .constant("")
        )

    }
    .padding()
}

