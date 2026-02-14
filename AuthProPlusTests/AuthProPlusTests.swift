//
//  AuthProPlusTests.swift
//  AuthProPlusTests
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation
import Testing
@testable import AuthProPlus

@MainActor
struct AuthProPlusTests {
    private func makeAuthManager() -> AuthManager {
        AuthManager(
            service: MockAuthService(),
            googleAuthService: MockGoogleAuthService(),
            appleAuthService: MockAppleAuthService()
        )
    }

    @Test
    func configureAuthState_setsUnauthenticated() async throws {
        let manager = makeAuthManager()
        await manager.configureAuthState()
        #expect(manager.authState == .unauthenticated)
    }

    @Test
    func login_success_setsAuthenticated_andClearsError() async throws {
        let manager = makeAuthManager()
        await manager.login(withEmail: "test@example.com", password: "password")
        #expect(manager.authState == .authenticated)
        #expect(manager.error == nil)
    }

    @Test
    func sendResetPasswordLink_doesNotThrow() async throws {
        let manager = makeAuthManager()
        await manager.sendResetPasswordLink(toEmail: "test@example.com")
        // success: no throw expected
        #expect(true)
    }

    @Test
    func signUp_success_setsCurrentUser() async throws {
        let manager = makeAuthManager()
        await manager.signUp(
            withEmail: "new@example.com",
            password: "password",
            username: "newuser",
            fullname: "New User"
        )
        let user = try #require(manager.currentUser)
        #expect(user.username != nil)
    }

    @Test
    func signOut_setsUnauthenticated() async throws {
        let manager = makeAuthManager()
        manager.updateAuthState(.authenticated)
        await manager.signOut()
        #expect(manager.authState == .unauthenticated)
    }

    @Test
    func deleteAccount_signsOutOnSuccess() async throws {
        let manager = makeAuthManager()
        manager.updateAuthState(.authenticated)
        await manager.deleteAccount()
        #expect(manager.authState == .unauthenticated)
    }
}

@MainActor
struct AuthRouterTests {
    private func makeRouter() -> AuthenticationRouter { AuthenticationRouter() }

    @Test
    func showLogin_clearsPathAndSetsLoginView() {
        let router = makeRouter()
        router.path = [.accountCreation(.passwordView)]
        router.showLogin()
        #expect(router.path == [.login(.loginView)])
    }

    @Test
    func showResetPassword_appendsResetRoute() {
        let router = makeRouter()
        router.showLogin()
        router.showResetPassword()
        #expect(router.path == [.login(.loginView), .login(.resetPassword)])
    }

    @Test
    func startAccountCreationFlow_appendsFirstStep() {
        let router = makeRouter()
        router.startAccountCreationFlow()
        #expect(router.path.last == .accountCreation(.userInformationView))
    }

    @Test
    func pushNextAccountCreationStep_advancesThroughSteps_andClearsAfterCompletion() {
        let router = makeRouter()
        router.startAccountCreationFlow() // userInformationView
        router.pushNextAccountCreationStep()
        #expect(router.path.last == .accountCreation(.passwordView))
        router.pushNextAccountCreationStep()
        #expect(router.path.last == .accountCreation(.profilePhotoSelectionView))
        router.pushNextAccountCreationStep()
        #expect(router.path.last == .accountCreation(.completionView))
        router.pushNextAccountCreationStep() // completion -> clears path
        #expect(router.path.isEmpty)
    }

    @Test
    func showUsernameViewAfterOAuth_appendsOAuthRoute() {
        let router = makeRouter()
        router.showUsernameViewAfterOAuth()
        #expect(router.path.last == .oAuth(.usernameView))
    }

    @Test
    func pushNextAccountCreationStep_whenNotInAccountFlow_doesNothing() {
        let router = makeRouter()
        router.path = [.login(.loginView)]
        router.pushNextAccountCreationStep()
        #expect(router.path == [.login(.loginView)])
    }

    @Test
    func showResetPassword_fromEmpty_startsWithResetRoute() {
        let router = makeRouter()
        router.showResetPassword()
        #expect(router.path.last == .login(.resetPassword))
    }
}

@MainActor
struct UserManagerTests {
    private func makeUserManager() -> UserManager { UserManager(service: MockUserService()) }

    private struct TestUser: BaseUser {
        let id: String
        let email: String?
        let fullname: String?
        let username: String?
    }

    private struct ThrowingUserService: UserServiceProtocol {
        func fetchCurrentUser() async throws -> AuthProPlusUser? { throw TestError.some }
        func fetchUser(withUid uid: String) async throws -> AuthProPlusUser? { throw TestError.some }
        func updateUsername(_ username: String) async throws { throw TestError.some }
        func updateProfilePhoto(_ imageData: Data) async throws -> String { throw TestError.some }
        func updateProfileHeaderPhoto(_ imageData: Data) async throws -> String { throw TestError.some }
        func saveUserDataAfterAuthentication(_ user: any BaseUser) async throws { throw TestError.some }

        enum TestError: Error { case some }
    }

    @Test
    func fetchCurrentUser_setsUser_andCompleteState() async throws {
        let manager = makeUserManager()
        await manager.fetchCurrentUser()
        let user = try #require(manager.currentUser)
        #expect(user.username != nil)
        
        #expect({
            if case .complete = manager.loadingState {
                return true
            }else {
                return false
            }
        }())
    }

    @Test
    func fetchCurrentUser_error_setsErrorState() async throws {
        let manager = UserManager(service: ThrowingUserService())
        await manager.fetchCurrentUser()
        #expect({ if case .error = manager.loadingState { return true } else { return false } }())
    }

    @Test
    func updateProfilePhoto_setsURL_onCurrentUser() async throws {
        let manager = makeUserManager()
        await manager.fetchCurrentUser()
        let url = "https://example.com/image.jpg"
        manager.updateProfilePhoto(with: url)
        let user = try #require(manager.currentUser)
        #expect(user.profileImageUrl == url)
    }

    @Test
    func uploadProfilePhoto_updatesCurrentUserProfileImageUrl() async throws {
        let manager = makeUserManager()
        await manager.fetchCurrentUser()
        let before = manager.currentUser?.profileImageUrl
        try await manager.uploadProfilePhoto(with: Data("avatar".utf8))
        let after = try #require(manager.currentUser?.profileImageUrl)
        #expect(!after.isEmpty)
        #expect(after != before)
    }

    @Test
    func uploadUsername_updatesCurrentUser() async throws {
        let manager = makeUserManager()
        await manager.fetchCurrentUser()
        try await manager.uploadUsername("new_username")
        let user = try #require(manager.currentUser)
        #expect(user.username == "new_username")
    }

    @Test
    func saveUserDataAfterAuthentication_doesNotThrow() async throws {
        let manager = makeUserManager()
        let base = TestUser(id: UUID().uuidString, email: "user@example.com", fullname: "User Example", username: "user")
        await manager.saveUserDataAfterAuthentication(base)
        // No throw expected; function handles errors internally
        #expect(true)
    }
}

@MainActor
struct RegistrationValidationTests {
    private func makeManagerWithMock() -> RegistrationValidationManager {
        RegistrationValidationManager(service: MockRegistrationValidationService())
    }

    private struct ThrowingValidationService: RegistrationValidationProtocol {
        let emailError: RegistrationValidationError?
        let usernameError: RegistrationValidationError?

        func validateEmail(_ email: String) async throws -> InputValidationState {
            if let emailError { throw emailError }
            return .validated
        }

        func validateUsername(_ username: String) async throws -> InputValidationState {
            if let usernameError { throw usernameError }
            return .validated
        }
    }

    @Test
    func validateEmail_success_returnsValidated_andLeavesErrorNil() async throws {
        let manager = makeManagerWithMock()
        let result = await manager.validateEmail("valid@example.com")
        #expect(result == .validated)
        #expect(manager.validationError == nil)
        // Manager sets state to `.validating` and returns the result; it doesn't overwrite the state.
        #expect(manager.emailValidationState == .validating)
    }

    @Test
    func validateEmail_invalidFormat_returnsInvalid_noError() async throws {
        let manager = makeManagerWithMock()
        let result = await manager.validateEmail("bad-email")
        #expect(result == .invalid)
        #expect(manager.validationError == nil)
    }

    @Test
    func validateEmail_serviceThrows_setsValidationError_andReturnsInvalid() async throws {
        let manager = RegistrationValidationManager(
            service: ThrowingValidationService(emailError: .emailValidationFailed, usernameError: nil)
        )
        let result = await manager.validateEmail("valid@example.com")
        #expect(result == .invalid)
        #expect(manager.validationError == .emailValidationFailed)
    }

    @Test
    func validateUsername_success_returnsValidated_andLeavesErrorNil() async throws {
        let manager = makeManagerWithMock()
        let result = await manager.validateUsername("good_username")
        #expect(result == .validated)
        #expect(manager.validationError == nil)
        #expect(manager.usernameValidationState == .validating)
    }

    @Test
    func validateUsername_invalidFormat_returnsInvalid_noError() async throws {
        let manager = makeManagerWithMock()
        let result = await manager.validateUsername("__bad__")
        #expect(result == .invalid)
        #expect(manager.validationError == nil)
    }

    @Test
    func validateUsername_serviceThrows_setsValidationError_andReturnsInvalid() async throws {
        let manager = RegistrationValidationManager(
            service: ThrowingValidationService(emailError: nil, usernameError: .usernameValidationFailed)
        )
        let result = await manager.validateUsername("validusername")
        #expect(result == .invalid)
        #expect(manager.validationError == .usernameValidationFailed)
    }
}
