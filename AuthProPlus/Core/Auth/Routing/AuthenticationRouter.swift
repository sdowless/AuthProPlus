//
//  AuthenticationRouter.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Observation

/// Observable router that coordinates navigation within the authentication flow.
///
/// Use this with a `NavigationStack` bound to `path` to push/pop routes defined in
/// `AuthenticationRoutes`. Methods below encapsulate common navigation actions.
@MainActor @Observable
class AuthenticationRouter {
    /// Navigation path used by `NavigationStack` to present authentication screens.
    var path = [AuthenticationRoutes]()
    
    /// Starts the account creation flow at its first step.
    func startAccountCreationFlow() {
        guard let firstStep = AccountCreationRoutes(rawValue: 0) else { return }
        path.append(.accountCreation(firstStep))
    }
    
    /// Clears the current path and shows the primary login screen.
    func showLogin() {
        path.removeAll()
        path.append(.login(.loginView))
    }
    
    /// Pushes the password reset screen on top of the current stack.
    func showResetPassword() {
        path.append(.login(.resetPassword))
    }
    
    /// Pushes the username selection view used after OAuth sign-in.
    func showUsernameViewAfterOAuth() {
        path.append(.oAuth(.usernameView))
    }
    
    /// Advances to the next step in the account creation flow.
    ///
    /// If the current step is the completion screen, this resets the path.
    func pushNextAccountCreationStep() {
        guard let currentStep = path.last,
              case .accountCreation(let accountCreationRoutes) = currentStep else {
            return
        }

        print("DEBUG: Trying to push next step..")
        switch accountCreationRoutes {
        case .userInformationView:
            path.append(.accountCreation(.passwordView))
        case .passwordView:
            path.append(.accountCreation(.profilePhotoSelectionView))
        case .profilePhotoSelectionView:
            path.append(.accountCreation(.completionView))
        case .completionView:
            path.removeAll()
        }
    }
}
