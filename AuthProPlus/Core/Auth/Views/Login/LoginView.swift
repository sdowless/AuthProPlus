//
//  LoginView.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.authDataStore) private var store
    @Environment(\.authRouter) private var router
    @Environment(\.authManager) private var authManager
    
    @State private var isAuthenticating = false
        
    var body: some View {
        @Bindable var store = store
        
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome Back")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter your login credentials to sign in.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 20) {
                ASTextField(
                    "name@example.com",
                    title: "Email",
                    text: $store.email
                )
                .textInputAutocapitalization(.never)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                
                ASTextField(
                    "Enter your password",
                    title: "Password",
                    isSecureField: true,
                    text: $store.password
                )
                .textContentType(.password)
            }
            .padding(.vertical, 24)
            
            Spacer()
            
            VStack(spacing: 20) {
                ASButton("Login") {
                    login()
                }
                .buttonStyle(.standard, isLoading: $isAuthenticating)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                Button { router.path.append(.login(.resetPassword)) } label: {
                    Text("Forgot password?")
                        .underline()
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primaryText)
                }
            }
        }
        .padding()
        .alert("Sign In Error", isPresented: .constant(authManager.error != nil)) {
            Button("OK") { authManager.error = nil }
        } message: {
            Text(authManager.error?.localizedDescription ?? "An unknown error occurred.")
        }
    }
}

private extension LoginView {
    func login() {
        Task {
            isAuthenticating = true
            await authManager.login(withEmail: store.email, password: store.password)
            isAuthenticating = false
        }
    }
    
    var formIsValid: Bool {
        return store.email.isValidEmail() && store.password.isValidPassword()
    }
}

#Preview {
    LoginView()
        .environment(
            AuthManager(
                service: MockAuthService(),
                googleAuthService: MockGoogleAuthService(),
                appleAuthService: AppleAuthService()
            )
        )
        .environment(AuthDataStore())
}
