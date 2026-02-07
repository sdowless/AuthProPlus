//
//  MockUserService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import Foundation

class MockUserService: UserServiceProtocol {
    var currentUser = MockData.currentUser
    
    func fetchCurrentUser() async throws -> AuthProPlusUser? {
        return currentUser
    }
    
    func fetchUser(withUid uid: String) async throws -> AuthProPlusUser? {
        return currentUser
    }
    
    func updateUsername(_ username: String) async throws {
        currentUser.username = username
    }
    
    func updateProfilePhoto(_ imageData: Data) async throws -> String {
        return UUID().uuidString
    }
    
    func updateProfileHeaderPhoto(_ imageData: Data) async throws -> String {
        return UUID().uuidString
    }
    
    func saveUserDataAfterAuthentication(_ user: any BaseUser) async throws {
        
    }
}
