//
//  RegistrationView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

struct UserInformationView: View {
    @Environment(\.authRouter) private var router
    @Environment(\.authDataStore) private var store
    
    @State private var validationManager = RegistrationValidationManager(service: RegistrationValidationService())
    @State private var emailValidation: InputValidationState = .idle
    @State private var usernameValidation: InputValidationState = .idle
    @State private var emailValidationTask: Task<Void, Never>?
    @State private var usernameValidationTask: Task<Void, Never>?
    
    var body: some View {
        @Bindable var store = store
        
        ZStack(alignment: .bottomTrailing) {
            VStack {
                Text("Create your account")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 20) {
                    FormInputField("Name", text: $store.name)
                        .textContentType(.name)
                    
                    FormInputField(
                        "Email address",
                        validationState: emailValidation,
                        errorMessage: "This email is not valid. Please try again.",
                        text: $store.email
                    )
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    
                    FormInputField(
                        "Username",
                        validationState: usernameValidation,
                        errorMessage: "This username is not valid. Please try again.",
                        text: $store.username
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }
                .padding(.vertical)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            XButton("Next") {
                router.pushNextAccountCreationStep()
            }
            .buttonStyle(.standard(size: .compact))
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
        }
        .onChange(of: store.username) { _, newValue in
            validateUsername(newValue)
        }
        .onChange(of: store.email) { _, newValue in
            validateEmail(newValue)
        }
        .onDisappear {
            emailValidationTask?.cancel()
            usernameValidationTask?.cancel()
        }
        .padding()
    }
}

private extension UserInformationView {
    var formIsValid: Bool {
        return store.name.isValidName() &&
        emailValidation == .validated &&
        usernameValidation == .validated
    }
    
    func validateEmail(_ email: String) {
        guard email.isValidEmail() else {
            emailValidationTask?.cancel()
            emailValidationTask = nil
            emailValidation = .idle
            return
        }

        emailValidationTask?.cancel()
        emailValidationTask = Task {
            await MainActor.run { emailValidation = .validating }
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }

            let result = await validationManager.validateEmail(email)
            guard !Task.isCancelled else { return }
            await MainActor.run { emailValidation = result }
        }
    }
    
    func validateUsername(_ username: String) {
        guard username.isValidUsername() else {
            usernameValidationTask?.cancel()
            usernameValidationTask = nil
            usernameValidation = .idle
            return
        }

        usernameValidationTask?.cancel()
        usernameValidationTask = Task {
            await MainActor.run { usernameValidation = .validating }
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }

            let result = await validationManager.validateUsername(username)
            guard !Task.isCancelled else { return }
            await MainActor.run { usernameValidation = result }
        }
    }
}

#Preview {
    UserInformationView()
}
