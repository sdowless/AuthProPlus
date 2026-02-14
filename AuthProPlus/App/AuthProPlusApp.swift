//
//  AuthProPlusApp.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Supabase
import FirebaseCore
import SwiftUI

@main
struct AuthProPlusApp: App {
    init() {
        let provider: AuthServiceProvider = AppConfig.provider
        
        if case .firebase = provider {
            FirebaseApp.configure()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
