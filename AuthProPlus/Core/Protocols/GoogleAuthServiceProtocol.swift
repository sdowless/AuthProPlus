//
//  GoogleAuthServiceProtocol.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/7/26.
//

import Foundation

protocol GoogleAuthServiceProtocol {
    func signIn() async throws -> GoogleAuthUser
}
