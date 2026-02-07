//
//  AccountCreationCompletionView.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 1/29/25.
//

import SwiftUI

struct AccountCreationCompletionView: View {
    @Environment(\.authManager.self) private var authManager
    @Environment(\.authDataStore) private var store
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            XLogoImageView()
                .padding()
            
            Text("Welcome to X, \(store.username)")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
                .multilineTextAlignment(.center)
            
            Text("Click below to complete registration and start using X")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            ASButton("Complete Sign Up") {
                authManager.updateAuthState(.authenticated)
            }
            .buttonStyle(.standard)
            
            Spacer()
        }
    }
}

#Preview {
    AccountCreationCompletionView()
}
