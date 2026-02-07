//
//  MockData.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation

struct MockData {
    static var currentUser = AuthProPlusUser(
        id: UUID().uuidString,
        username: "test_user",
        email: "test@gmail.com",
        isPrivate: false,
        createdAt: Date()
    )
}
