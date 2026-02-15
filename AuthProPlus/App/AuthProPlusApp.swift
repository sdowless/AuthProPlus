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
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
