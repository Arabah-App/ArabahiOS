//
//  ProfileViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class ProfileViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Get Profile Tests
    
    func testGetProfileSuccess() {
        let mockService = MockAuthService()
        
        
        mockService.getProfilePublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        )).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Get profile success")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .profileLoaded(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: nil,
            actionType: .getProfile
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetProfileFailure() {
        let mockService = MockAuthService()
        let expectedError = NetworkError.unauthorized
        
        mockService.getProfilePublisher = Fail(error: expectedError)
            .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Get profile failure")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .loadProfilefailure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: nil,
            actionType: .getProfile
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Notification Update Tests
    
    func testUpdateNotificationSuccess() {
        let mockService = MockAuthService()
        let testStatus = 0
        
        mockService.updateNotiStatusPublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        )).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Update notification success")
        
        // Set initial user details
        Store.userDetails = LoginModal(
            success: true,
            code: 200,
            message: "",
            body: nil
        )
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .notificationUpdated = state {
                    XCTAssertEqual(Store.userDetails?.body?.isNotification, testStatus)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: testStatus,
            actionType: .updateNotification(testStatus)
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateNotificationFailure() {
        let mockService = MockAuthService()
        let expectedError = NetworkError.badRequest(message: "Update failed")
        
        mockService.updateNotiStatusPublisher = Fail(error: expectedError)
            .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Update notification failure")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .notiUpdatefailure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: 1,
            actionType: .updateNotification(1)
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetryUpdateNotification() {
        let mockService = MockAuthService()
        let testStatus = 1
        var callCount = 0
        
        mockService.updateNotiStatusPublisher = Deferred {
            Future<LoginModal, NetworkError> { promise in
                callCount += 1
                if callCount == 1 {
                    promise(.failure(.badRequest(message: "First failure")))
                } else {
                    promise(.success(LoginModal(
                        success: true,
                        code: 200,
                        message: "Success",
                        body: nil
                    )))
                }
            }
        }.eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Retry update notification")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .notiUpdatefailure = state {
                    viewModel.retryUpdateNotiStatus()
                    expectation.fulfill()
                } else if case .notificationUpdated = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: testStatus,
            actionType: .updateNotification(testStatus)
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Delete Account Tests
    
    func testDeleteAccountSuccess() {
        let mockService = MockAuthService()
        
        mockService.deleteAccountPublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        )).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Delete account success")
        
        // Set initial auth token to verify it gets cleared
        Store.authToken = "test_token"
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .accountDeleted = state {
                    XCTAssertNil(Store.authToken)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: nil,
            actionType: .deleteAccount
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetryDeleteAccount() {
        let mockService = MockAuthService()
        var callCount = 0
        
        mockService.deleteAccountPublisher = Deferred {
            Future<LoginModal, NetworkError> { promise in
                callCount += 1
                if callCount == 1 {
                    promise(.failure(.badRequest(message: "First failure")))
                } else {
                    promise(.success(LoginModal(
                        success: true,
                        code: 200,
                        message: "Success",
                        body: nil
                    )))
                }
            }
        }.eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Retry delete account")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .accDeletefailure = state {
                    viewModel.retryDeleteAccount()
                    expectation.fulfill()
                } else if case .accountDeleted = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: nil,
            actionType: .deleteAccount
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Logout Tests
    
    func testLogoutSuccess() {
        let mockService = MockAuthService()
        
        mockService.logoutPublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        )).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Logout success")
        
        // Set initial values to verify they get cleared
        Store.authToken = "test_token"
        Store.autoLogin = true
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .loggedOut = state {
                    XCTAssertNil(Store.authToken)
                    XCTAssertFalse(Store.autoLogin)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: nil,
            actionType: .logout
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Profile Completion Tests
    
    func testShouldShowCompleteProfile() {
        let viewModel = ProfileViewModel()
        
        // Test with complete profile
        Store.userDetails = LoginModal(
            success: true,
            code: 200,
            message: "",
            body: nil
        )
        XCTAssertFalse(viewModel.shouldShowCompleteProfile())
        
        // Test with missing name
        Store.userDetails?.body?.name = nil
        XCTAssertTrue(viewModel.shouldShowCompleteProfile())
        
        // Test with missing email
        Store.userDetails?.body?.name = "Test User"
        Store.userDetails?.body?.email = nil
        XCTAssertTrue(viewModel.shouldShowCompleteProfile())
        
        // Test with missing image
        Store.userDetails?.body?.email = "test@example.com"
        Store.userDetails?.body?.image = nil
        XCTAssertTrue(viewModel.shouldShowCompleteProfile())
        
        // Test with no user details
        Store.userDetails = nil
        XCTAssertTrue(viewModel.shouldShowCompleteProfile())
    }
}

