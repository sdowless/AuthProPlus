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
    @Environment(\.authManager.self) private var authManager
    @Environment(\.userManager.self) private var userManager

    @State private var router = AuthenticationRouter()
    @State private var dataStore = AuthDataStore()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                XLogoImageView()
                    .padding()
                
                Spacer()
                
                Text("See what's happening in the world right now.")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    
                    ASButton("Continue with Google", imageResource: .googleIcon) {
                        signInWithGoogle()
                    }
                    .buttonStyle(.standard(rank: .secondary))

                    ASButton("Continue with Apple", systemImage: "apple.logo") {
                        signInwithApple()
                    }
                    .buttonStyle(.standard(rank: .secondary))
                    
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
                    .buttonStyle(.standard(rank: .secondary))

                    VStack(alignment: .leading, spacing: 24) {
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
                                
                                Text("Log in")
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
                saveUserDataAndShowContinueOnboarding(user)
            }
            .task(id: authManager.currentUser != nil) {
                print("DEBUG: Task fired..")

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
                .environment(\.authRouter, router)
                .environment(\.authDataStore, dataStore)
            }
        }
        .onChange(of: router.path) { oldValue, newValue in
            print("DEBUG: Path is \(newValue)")
        }
    }
}

private extension AuthenticationRootView {
    func signInWithGoogle() {
        Task { await authManager.signInWithGoogle() }
    }
    
    func signInwithApple() {
        authManager.requestAppleAuthorization()
    }
    
    func saveUserDataAndShowContinueOnboarding(_ user: any BaseUser) {
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
                appleAuthService: AppleAuthService()
            )
        )
        .environment(UserManager(service: MockUserService()))
}

