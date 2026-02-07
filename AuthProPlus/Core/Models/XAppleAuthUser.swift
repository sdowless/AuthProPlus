//
//  XAppleAuthUser.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import Foundation

struct XAppleAuthUser: BaseUser {
    let id: String
    let isNewUser: Bool
    let email: String?
    let fullname: String?
    var username: String = ""
}
