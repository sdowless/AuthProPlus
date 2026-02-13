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
                    .transition(.opacity)
            case .unauthenticated:
                AuthenticationRootView()
                    .transition(.move(edge: .leading))
            case .authenticated:
                Group {
                    switch userManager.loadingState {
                    case .loading, .empty:
                        ProgressView()
                            .transition(.opacity)
                    case .error(let error):
                        Text(error.localizedDescription)
                            .transition(.opacity)
                    case .complete:
                        VStack {
                            Text("Your home screen goes here!")
                            
                            ASButton("Sign Out") {
                                Task { await authManager.signOut() }
                            }
                            .buttonStyle(.standard)
                        }
                        .transition(.move(edge: .trailing))
                    }
                }
            }
        }
        .animation(.easeInOut, value: authManager.authState)
        .animation(.easeInOut, value: userManager.loadingState)
        .task { await authManager.configureAuthState() }
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
