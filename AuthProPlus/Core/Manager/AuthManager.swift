//
//  AuthManager.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import AuthenticationServices
import Foundation
import GoogleSignIn

@MainActor
@Observable
class AuthManager: NSObject {
    var authState: AuthenticationState = .notDetermined
    var error: AuthError?
    var currentUser: (any BaseUser)?
    
    private let service: AuthServiceProtocol
    private let googleAuthService: GoogleAuthServiceProtocol
    private let appleAuthService: AppleAuthServiceProtocol
    
    private var currentNonce: String?
    
    init(
        service: AuthServiceProtocol,
        googleAuthService: GoogleAuthServiceProtocol,
        appleAuthService: AppleAuthServiceProtocol
    ) {
        self.service = service
        self.googleAuthService = googleAuthService
        self.appleAuthService = appleAuthService
    }
    
    func configureAuthState() {
        self.authState = service.getAuthState()
    }
    
    func deleteAccount() async {
        do {
            try await service.deleteAccount()
            signOut()
        } catch {
            print("DEBUG: Failed to delete account with error: \(error)")
        }
    }
    
    func login(withEmail email: String, password: String) async {
        clearError()

        do {
            self.authState = try await service.login(withEmail: email, password: password)
        } catch {
            self.error = .general(error as? FirebaseAuthError ?? .unknown)
        }
    }
    
    func sendResetPasswordLink(toEmail email: String) async throws {
        try await service.sendResetPasswordLink(toEmail: email)
    }
    
    func signUp(withEmail email: String, password: String, username: String, fullname: String) async throws {
        self.currentUser = try await service.createUser(
            withEmail: email,
            password: password,
            username: username,
            fullname: fullname
        )
    }
    
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
    
    func signOut() {
        service.signout()
        authState = .unauthenticated
    }
    
    func updateAuthState(_ state: AuthenticationState) {
        self.authState = state
    }
    
    private func clearError() {
        error = nil
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
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
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            do {
                guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    self.error = .apple(.invalidIdentityToken)
                    return
                }
                
                let appleAuthUser = try await appleAuthService.signInWithApple(appleIDCredential, nonce: currentNonce)
                
                if appleAuthUser.requiresUsername {
                    print("DEBUG: Is new user")
                    self.currentUser = appleAuthUser
                } else {
                    print("DEBUG: Is not new user. Proceed with sign in.")
                    updateAuthState(.authenticated)
                }
            } catch {
                print("DEBUG: Error signing in with apple \(error.localizedDescription)")
                self.error = .apple(error as? AppleAuthError ?? .unknown)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.error = .apple(.unknown)
        print("DEBUG: Failed with error: \(error)")
    }
}

