//
//  AuthServiceProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation

protocol AuthServiceProtocol {
    func createUser(withEmail email: String, password: String, username: String, fullname: String) async throws -> User
    func deleteAccount() async throws
    func getAuthState() -> AuthenticationState
    func login(withEmail email: String, password: String) async throws -> AuthenticationState
    func sendResetPasswordLink(toEmail email: String) async throws
    func signout()
}
