//
//  UserServiceProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import FirebaseAuth
import FirebaseFirestore

protocol UserServiceProtocol {
    func fetchCurrentUser() async throws -> AuthProPlusUser?
    func fetchUser(withUid uid: String) async throws -> AuthProPlusUser?
    func updateUsername(_ username: String) async throws
    func updateProfilePhoto(_ imageData: Data) async throws -> String
    func updateProfileHeaderPhoto(_ imageData: Data) async throws -> String
    func saveUserDataAfterAuthentication(_ user: any BaseUser) async throws
}

struct UserService: UserServiceProtocol {
    private let imageUploader = ImageUploader()
    
    func fetchCurrentUser() async throws -> AuthProPlusUser? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
                
        return try await FirestoreConstants
            .UserCollection
            .document(uid)
            .getDocument(as: AuthProPlusUser.self)
    }
    
    func fetchUser(withUid uid: String) async throws -> AuthProPlusUser? {
        return try? await FirestoreConstants
            .UserCollection.document(uid)
            .getDocument(as: AuthProPlusUser.self)
    }
    
    func updateUsername(_ username: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await FirestoreConstants.UserCollection.document(uid).updateData(["username": username])
    }
    
    func updateProfilePhoto(_ imageData: Data) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else { throw FirebaseAuthError.userNotFound }
        let imageUrl = try await imageUploader.uploadImage(imageData: imageData, type: .profilePhoto)
        try await FirestoreConstants.UserCollection.document(uid).updateData(["profileImageUrl": imageUrl])
        return imageUrl
    }
    
    func updateProfileHeaderPhoto(_ imageData: Data) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else { throw FirebaseAuthError.userNotFound }
        let imageUrl = try await imageUploader.uploadImage(imageData: imageData, type: .profileHeaderPhoto)
        try await FirestoreConstants.UserCollection.document(uid).updateData(["profileHeaderImageUrl": imageUrl])
        return imageUrl
    }
    
    func saveUserDataAfterAuthentication(_ baseUser: any BaseUser) async throws {
        let user = AuthProPlusUser(
            id: baseUser.id,
            username: baseUser.username,
            email: baseUser.email,
            isPrivate: false,
            createdAt: Date()
        )
        
        let encodedUser = try Firestore.Encoder().encode(user)
        try await FirestoreConstants.UserCollection.document(user.id).setData(encodedUser)
    }
}
