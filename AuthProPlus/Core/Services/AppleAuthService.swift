//
//  AppleAuthService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth

struct AppleAuthService {
    func signInWithApple(_ appleIDCredential: ASAuthorizationAppleIDCredential, nonce: String?) async throws -> XAppleAuthUser {
        guard let appleIDToken = appleIDCredential.identityToken else {
            throw AppleAuthError.invalidIdentityToken
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AppleAuthError.invalidIdentityToken
        }
        
        guard let nonce else {
            throw AppleAuthError.invalidNonce
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        let firebaseAuthResult: AuthDataResult
        do {
            firebaseAuthResult = try await Auth.auth().signIn(with: credential)
        } catch {
            throw AppleAuthError.authorizationFailed(underlying: error)
        }
        
        let isNewUser = firebaseAuthResult.additionalUserInfo?.isNewUser ?? false
        
        var name: String?
        
        if let nameComponents = appleIDCredential.fullName {
            let formatter = PersonNameComponentsFormatter()
            formatter.style = .medium
            name = formatter.string(from: nameComponents)
        }
        
        return XAppleAuthUser(
            id: firebaseAuthResult.user.uid,
            isNewUser: isNewUser,
            email: appleIDCredential.email ?? firebaseAuthResult.user.email,
            fullname: name
        )
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

