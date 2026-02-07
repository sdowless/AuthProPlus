//
//  AuthDataStore.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Observation
import SwiftUI

@Observable
class AuthDataStore {
    var email = ""
    var username = ""
    var name = ""
    var password = ""
    var profileImage: Image?
}
