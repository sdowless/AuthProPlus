//
//  ContentView.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.authManager.self) private var authManager
    @Environment(\.userManager.self) private var userManager

    var body: some View {
        Group {
            switch authManager.authState {
            case .notDetermined, .authenticating:
                ProgressView()
            case .unauthenticated:
                AuthenticationRootView()
            case .authenticated:
                switch userManager.loadingState {
                case .loading, .empty:
                    ProgressView()
                case .error(let error):
                    Text(error.localizedDescription)
                case .complete:
                    VStack {
                        Text("Your home screen goes here!")
                        
                        XButton("Sign Out") {
                            authManager.signOut()
                        }
                        .buttonStyle(.standard)
                    }
                }
            }
        }
        .onAppear { authManager.configureAuthState() }
        .task(id: authManager.authState) {
            guard authManager.authState == .authenticated else { return }
            await userManager.fetchCurrentUser()
        }
    }
}

#Preview {
    ContentView()
        .environment(
            AuthManager(
                service: MockAuthService(),
                googleAuthService: MockGoogleAuthService(),
                appleAuthService: AppleAuthService()
            )
        )
        .environment(UserManager(service: MockUserService()))
}
