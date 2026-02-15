//
//  PasswordResetView.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/7/26.
//

import SwiftUI

struct PasswordResetView: View {
    @Environment(\.authManager) private var authManager
    @Environment(\.authDataStore) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var isSending = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        @Bindable var store = store
        
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Reset your password")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 20) {
                ASTextField("name@example.com", title: "Email", text: $store.email)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
            }
            .padding(.vertical, 24)

            Spacer()

            ASButton("Send Reset Link") {
                sendReset()
            }
            .buttonStyle(.standard, isLoading: $isSending)
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
        }
        .padding()
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                showingAlert = false
                if alertTitle != "Error" {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
        alert("Error", isPresented: .constant(authManager.error != nil)) {
            Button("OK", role: .cancel) { authManager.error = nil }
        } message: {
            Text(alertMessage)
        }
    }
}

private extension PasswordResetView {
    var formIsValid: Bool {
        store.email.isValidEmail()
    }

    func sendReset() {
        Task {
            isSending = true
            
            await authManager.sendResetPasswordLink(toEmail: store.email)
            alertTitle = "Email Sent"
            alertMessage = "Check your email for a link to reset your password."
            
            isSending = false
            showingAlert = true
            
            dismiss()
        }
    }
}

#Preview {
    PasswordResetView()
        .environment(
            AuthManager(
                service: MockAuthService(),
                googleAuthService: MockGoogleAuthService(),
                appleAuthService: MockAppleAuthService()
            )
        )
        .environment(AuthDataStore())
}
