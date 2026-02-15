//
//  AuthManager.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import AuthenticationServices
import Foundation
import GoogleSignIn

/// Central coordinator for authentication flows and state.
///
/// `AuthManager` drives sign-in, sign-up, and sign-out flows using injected services
/// for email/password, Google, and Apple Sign In. It exposes an `authState` that the UI
/// can observe to switch between unauthenticated and authenticated experiences.
///
/// - Note: Marked `@MainActor` because it updates UI-observed state.
@MainActor @Observable
final class AuthManager: NSObject {
    /// Current authentication state for the app.
    var authState: AuthenticationState = .notDetermined
    /// The most recent authentication-related error.
    var error: AuthError?
    /// A partially created or signed-in user model (may be used during onboarding).
    var currentUser: (any BaseUser)?
    /// Flag tthat tracks Apple authentication state
    var appleAuthInProgress = false
    
    private let service: AuthServiceProtocol
    private let googleAuthService: GoogleAuthServiceProtocol
    private let appleAuthService: AppleAuthServiceProtocol
    
    private var currentNonce: String?
    
    /// Creates an `AuthManager` with the required service dependencies.
    init(
        service: AuthServiceProtocol,
        googleAuthService: GoogleAuthServiceProtocol,
        appleAuthService: AppleAuthServiceProtocol
    ) {
        self.service = service
        self.googleAuthService = googleAuthService
        self.appleAuthService = appleAuthService
    }
    
    /// Reads the persisted authentication state from the underlying service.
    func configureAuthState() async {
        do {
            self.authState = try await service.getAuthState()
        } catch {
            self.error = .supabase(error as? SupabaseAuthError ?? .unknown)
        }
    }
    
    /// Deletes the current user's account and signs out on success.
    func deleteAccount() async {
        do {
            try await service.deleteAccount()
            await signOut()
        } catch {
            self.error = .supabase(error as? SupabaseAuthError ?? .unknown)
        }
    }
    
    /// Attempts to sign in with email and password.
    ///
    /// On success, updates `authState`. On failure, sets `error` with context.
    func login(withEmail email: String, password: String) async {
        clearError()

        do {
            self.authState = try await service.login(withEmail: email, password: password)
        } catch {
            self.error = .supabase(error as? SupabaseAuthError ?? .unknown)
        }
    }
    
    /// Sends a password reset link to the provided email address.
    func sendResetPasswordLink(toEmail email: String) async {
        do {
            try await service.sendResetPasswordLink(toEmail: email)
        } catch {
            self.error = .supabase(error as? SupabaseAuthError ?? .unknown)
        }
    }
    
    /// Creates a new user with email/password and stores a temporary user for onboarding.
    func signUp(withEmail email: String, password: String, username: String, fullname: String) async {
        clearError()
        
        do {
            self.currentUser = try await service.createUser(
                withEmail: email,
                password: password,
                username: username,
                fullname: fullname
            )
        } catch {
            self.error = .supabase(error as? SupabaseAuthError ?? .unknown)
        }
    }
    
    /// Signs out the current user and sets the state to unauthenticated.
    func signOut() async {
        clearError()
        
        do {
            try await service.signout()
            authState = .unauthenticated
        } catch {
            self.error = .supabase(error as? SupabaseAuthError ?? .unknown)
        }
    }
    
    /// Manually updates the authentication state.
    func updateAuthState(_ state: AuthenticationState) {
        self.authState = state
    }
    
    private func clearError() {
        error = nil
    }
}

// MARK: - Sign in with Google
extension AuthManager {
    /// Initiates Google Sign-In and updates state or stores a partial user if a username is required.
    func signInWithGoogle() async {
        do {
            let user = try await googleAuthService.signIn()
            
            if user.requiresUsername {
                self.currentUser = user
            } else {
                updateAuthState(.authenticated)
            }
        } catch {
            self.error = .google(error as? GoogleAuthError ?? .unknown)
        }
    }
}

// MARK: - Sign in with Apple
extension AuthManager: ASAuthorizationControllerDelegate {
    /// Starts the Sign in with Apple authorization flow.
    func requestAppleAuthorization() {
        let nonce = appleAuthService.randomNonceString(length: 32)
        self.currentNonce = nonce
        
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = appleAuthService.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    /// Handles successful completion of the Apple authorization flow.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            appleAuthInProgress = true
            defer { appleAuthInProgress = false }
            
            do {
                guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    self.error = .apple(.invalidIdentityToken)
                    return
                }
                                
                let appleAuthUser = try await appleAuthService.signInWithApple(appleIDCredential, nonce: currentNonce)
                
                if appleAuthUser.requiresUsername {
                    self.currentUser = appleAuthUser
                } else {
                    updateAuthState(.authenticated)
                }
            } catch {
                print("DEBUG: Error \(error)")
                self.error = .apple(error as? AppleAuthError ?? .unknown)
            }
        }
    }
    
    /// Handles errors during the Apple authorization flow.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("DEBUG: Error \(error)")
        self.error = .apple(.unknown)
    }
}

