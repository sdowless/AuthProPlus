//
//  PasswordView.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

struct CreatePasswordView: View {
    @Environment(\.authDataStore) private var store
    @Environment(\.authManager) private var authManager
    @Environment(\.authRouter) private var authRouter

    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        @Bindable var store = store
        
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("You'll need a password")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Make sure it's \(AppConstants.minimumPasswordCount) characters or more.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                ASTextField(
                    "Enter your password",
                    title: "Password",
                    isSecureField: true,
                    text: $store.password
                )
                .textContentType(.password)
            }
                        
            VStack(spacing: 20) {
                Link(destination: URL(string: AppConstants.termsOfServiceURLString)!) {
                    HStack(spacing: 2) {
                        Text("By signing up, you agree to our")
                        
                        Text("Terms and Conditions")
                            .fontWeight(.semibold)
                    }
                }
                .font(.footnote)
                .foregroundStyle(.gray)
                
                ASButton("Sign up") {
                    onSignUp()
                }
                .buttonStyle(.standard, isLoading: $isLoading)
                .disabled(!password.isValidPassword())
                .opacity(password.isValidPassword() ? 1.0 : 0.4)
            }
            
            Spacer()
        }
        .padding()
        .alert("Sign In Error", isPresented: .constant(authManager.error != nil)) {
            Button("OK") { authManager.error = nil }
        } message: {
            Text(authManager.error?.localizedDescription ?? "An unknown error occurred.")
        }
    }
}

private extension CreatePasswordView {
    func onSignUp() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            await authManager.signUp(
                withEmail: store.email,
                password: store.password,
                username: store.username,
                fullname: store.name
            )
        }
    }
    
    var password: String {
        return store.password
    }
}

#Preview {
    CreatePasswordView()
}
