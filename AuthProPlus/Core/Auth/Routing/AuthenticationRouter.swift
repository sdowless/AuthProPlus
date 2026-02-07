//
//  AuthenticationRouter.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Observation

@Observable
class AuthenticationRouter {
    var path = [AuthenticationRoutes]()
    
    func startAccountCreationFlow() {
        guard let firstStep = AccountCreationRoutes(rawValue: 0) else { return }
        path.append(.accountCreation(firstStep))
    }
    
    init() {
        print("DEBUG: Did init..")
    }
    
    func showLogin() {
        path.removeAll()
        path.append(.login(.loginView))
        print("DEBUG: Path: \(path)")
    }
    
    func showResetPassword() {
        print("DEBUG: Called")
        path.append(.login(.resetPassword))
        print("DEBUG: Path: \(path)")
    }
    
    func showUsernameViewAfterOAuth() {
        path.append(.oAuth(.usernameView))
    }
    
    func pushNextAccountCreationStep() {
        guard let currentStep = path.last,
              case .accountCreation(let accountCreationRoutes) = currentStep else {
            print("No valid account creation step found.")
            return
        }

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
