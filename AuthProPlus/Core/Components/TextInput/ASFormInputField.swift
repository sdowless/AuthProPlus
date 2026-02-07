//
//  ASFormInputField.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import SwiftUI

/// A reusable text input field with optional validation UI.
///
/// Supports secure text entry, a floating title label, and inline validation feedback
/// via `InputValidationState` (progress, invalid, validated) and an optional error message.
struct ASFormInputField: View {
    /// The bound text value for the input.
    @Binding private var text: String
    
    /// The placeholder and floating title text.
    private let titleKey: String
    /// The current validation state used to drive inline indicators.
    private let validationState: InputValidationState
    /// An optional error message shown when `validationState` is `.invalid`.
    private let errorMessage: String?
    /// Whether the field should obscure input (e.g., for passwords).
    private let isSecureField: Bool
    
    /// Creates a form input field.
    /// - Parameters:
    ///   - titleKey: The placeholder and floating title text.
    ///   - validationState: The validation state that controls inline indicators. Defaults to `.idle`.
    ///   - errorMessage: An optional error message displayed when the state is `.invalid`.
    ///   - isSecureField: Whether to obscure input (secure entry). Defaults to `false`.
    ///   - text: A binding to the text value.
    init(
        _ titleKey: String,
        validationState: InputValidationState = .idle,
        errorMessage: String? = nil,
        isSecureField: Bool = false,
        text: Binding<String>
    ) {
        _text = text
        
        self.titleKey = titleKey
        self.validationState = validationState
        self.errorMessage = errorMessage
        self.isSecureField = isSecureField
    }
    
    /// The field content, including floating label, input, divider, and optional validation UI.
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(alignment: .leading) {
                if !text.isEmpty {
                    Text(titleKey)
                        .foregroundStyle(.primary.opacity(0.87))
                        .font(.footnote)
                }
                
                HStack {
                    Group {
                        if isSecureField {
                            SecureField(titleKey, text: $text)
                        } else {
                            TextField(titleKey, text: $text)
                        }
                    }
                    .font(.subheadline)
                    .padding(.top, 4)

                    Spacer()
                    
                    switch validationState {
                    case .idle:
                        EmptyView()
                    case .validating:
                        ProgressView()
                    case .invalid:
                        Image(systemName: "exclamationmark.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(.red)
                    case .validated:
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(.green)
                    }
                }
                
                Divider()
                
                if validationState == .invalid, let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ASFormInputField("Name", text: .constant(""))
        ASFormInputField("Name", validationState: .validating, text: .constant(""))
        ASFormInputField("Name", validationState: .invalid, text: .constant(""))
        ASFormInputField("Name", validationState: .validated, text: .constant(""))
        
        ASFormInputField(
            "Name",
            validationState: .invalid,
            errorMessage: "An error ocurred. Please try again.",
            text: .constant("")
        )

    }
    .padding()
}

