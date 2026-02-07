//
//  AuthenticationRoutes.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import SwiftUI

enum AuthenticationRoutes: Hashable {
    case login(LoginRoutes)
    case accountCreation(AccountCreationRoutes)
    case oAuth(OAuthRoutes)
}


enum LoginRoutes: Int, Hashable {
    case loginView
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .loginView:
            LoginView()
        }
    }
}

enum AccountCreationRoutes: Int, Hashable {
    case userInformationView
    case passwordView
    case profilePhotoSelectionView
    case profileHeaderPhotoSelectionView
    case completionView
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .userInformationView:
            UserInformationView()
        case .passwordView:
            CreatePasswordView()
        case .profilePhotoSelectionView:
            ProfileImageSelectorView()
        case .profileHeaderPhotoSelectionView:
            ProfileHeaderImageSelectorView()
        case .completionView:
            AccountCreationCompletionView()
        }
    }
}

enum OAuthRoutes: Int, Hashable {
    case usernameView
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .usernameView:
            AddUsernameView()
        }
    }
}