//
//  AuthenticationRootView.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import AuthenticationServices
import GoogleSignIn
import SwiftUI

struct AuthenticationRootView: View {
    @Environment(\.authManager) private var authManager
    @Environment(\.userManager) private var userManager
    @Environment(\.authRouter) private var router
    @Environment(\.authDataStore) private var dataStore
    
    var body: some View {
        @Bindable var authManager = authManager
        @Bindable var router = router
        
        NavigationStack(path: $router.path) {
            VStack {
                Image(systemName: "square.on.square")
                    .resizable()
                    .frame(width: 112, height: 112)
                    .padding()
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Secure authentication made simple.")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Auth Pro Plus")
                        .foregroundStyle(.secondary)
                        .font(.headline)
                }
                .padding(.leading, 32)

                
                Spacer()
                
                VStack(spacing: 12) {
                    
                    ASButton("Continue with Google", imageResource: .googleIcon) {
                        signInWithGoogle()
                    }
                    .buttonStyle(
                        .standard(rank: .secondary),
                        isLoading: $authManager.googleAuthInProgress
                    )

                    ASButton("Continue with Apple", systemImage: "apple.logo") {
                        signInwithApple()
                    }
                    .buttonStyle(
                        .standard(rank: .secondary),
                        isLoading: $authManager.appleAuthInProgress
                    )
                    
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                        
                        Text("or")
                            .font(.subheadline)
                        
                        Rectangle()
                            .frame(height: 1)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    
                    ASButton("Create Account") {
                        router.startAccountCreationFlow()
                    }
                    .buttonStyle(.standard(rank: .primary))

                    VStack(alignment: .leading, spacing: 16) {
                        Link(destination: URL(string: AppConstants.termsOfServiceURLString)!) {
                            HStack(spacing: 2) {
                                Text("By signing up, you agree to our")
                                
                                Text("Terms and Conditions")
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        
                        Button { router.path.append(.login(.loginView)) } label: {
                            HStack(spacing: 2) {
                                Text("Have an account already?")
                                    .foregroundStyle(.gray)
                                
                                Text(" Log in")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .font(.footnote)
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 8)
                }
            }
            .onChange(of: authManager.currentUser?.id) { oldValue, newValue in
                guard let user = authManager.currentUser else { return }
                saveUserDataAndContinueOnboarding(user)
            }
            .navigationDestination(for: AuthenticationRoutes.self) { route in
                Group {
                    switch route {
                    case .login(let loginRoute):
                        loginRoute.destination
                    case .accountCreation(let accountCreationRoute):
                        accountCreationRoute.destination
                    case .oAuth(let oAuthRoute):
                        oAuthRoute.destination
                    }
                }
            }
        }
        .alert("Authentication Error", isPresented: .constant(authManager.error != nil), actions: {
            Button("OK", role: .cancel) { authManager.error = nil }
        }, message: {
            Text(authManager.error?.localizedDescription ?? "An unknown error ocurred. Please try again.")
        })
    }
}

private extension AuthenticationRootView {
    func signInWithGoogle() {
        Task { await authManager.signInWithGoogle() }
    }
    
    func signInwithApple() {
        authManager.requestAppleAuthorization()
    }
    
    func saveUserDataAndContinueOnboarding(_ user: any BaseUser) {
        Task {
            await userManager.saveUserDataAfterAuthentication(user)
            
            if user.requiresUsername {
                router.showUsernameViewAfterOAuth()
            } else {
                router.pushNextAccountCreationStep()
            }
        }
    }
}

#Preview {
    AuthenticationRootView()
        .environment(
            AuthManager(
                service: MockAuthService(),
                googleAuthService: MockGoogleAuthService(),
                appleAuthService: MockAppleAuthService()
            )
        )
        .environment(UserManager(service: MockUserService()))
}

