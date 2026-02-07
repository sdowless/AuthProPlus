//
//  XAppleAuthUser.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import Foundation

struct AppleAuthUser: BaseUser {
    let id: String
    let email: String?
    let fullname: String?
    var username: String = ""
}
