//
//  AuthProPlusApp.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import FirebaseCore
import SwiftUI

@main
struct AuthProPlusApp: App {
    @State private var authManager = AuthManager(
        service: FirebaseAuthService(),
        googleAuthService: GoogleAuthService(),
        appleAuthService: AppleAuthService()
    )
    @State private var userManager = UserManager(service: UserService())
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.authManager, authManager)
                .environment(\.userManager, userManager)
        }
    }
}
