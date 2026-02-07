//
//  User.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation

protocol BaseUser: Identifiable, Hashable {
    var id: String { get }
    var email: String? { get }
    var fullname: String? { get }
    var username: String { get }
}

extension BaseUser {
    var requiresUsername: Bool { username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

struct AuthProPlusUser: BaseUser, Codable {
    let id: String
    var username: String
    var profileImageUrl: String?
    var profileHeaderImageUrl: String?
    var fullname: String?
    var bio: String?
    let email: String?
    var isPrivate: Bool
    var createdAt: Date
    var lastActiveAt: Date?
}

