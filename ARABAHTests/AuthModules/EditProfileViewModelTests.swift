//
//  EditProfileViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class EditProfileViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Profile Update Tests
    
    func testCompleteProfileSuccess() {
        let mockService = MockAuthService()
        let loginModalBody = LoginModalBody(id: "1", role: 1, name: "test", email: "test@gmail.com", password: "", phone: "9856523355", phoneNnumberWithCode: "+919856523355", image: "", countryCode: "+91", status: 0, authToken: "testAuthToken", deviceToken: "testdeviceToken", deviceType: "1", isNotification: 1, socialtype: "1", otp: 0, otpVerify: 1, isProfileComplete: 1, forgotPasswordToken: "", isDeleted: false, createdAt: "", updatedAt: "", v: 1, loginTime: 0, token: "testToken")
        let expectedResponse = LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: loginModalBody
        )
        
        mockService.completeProfilePublisher = Just(expectedResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = EditProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Complete profile success")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let response) = state {
                    XCTAssertEqual(response.body?.token, expectedResponse.body?.token)
                    XCTAssertEqual(Store.userDetails?.body?.name, "Test User")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let testImage = UIImage(systemName: "person.circle")!
        viewModel.completeProfleAPI(
            name: "Test User",
            email: "test@example.com",
            needImageUpdate: true,
            image: testImage
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCompleteProfileFailure() {
        let mockService = MockAuthService()
        let expectedError = NetworkError.badRequest(message: "Update failed")
        
        mockService.completeProfilePublisher = Fail(error: expectedError)
            .eraseToAnyPublisher()
        
        let viewModel = EditProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Complete profile failure")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let testImage = UIImage(systemName: "person.circle")!
        viewModel.completeProfleAPI(
            name: "Test User",
            email: "test@example.com",
            needImageUpdate: true,
            image: testImage
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Input Validation Tests
    
    func testValidateInputsSuccess() {
        let viewModel = EditProfileViewModel()
        let isValid = viewModel.validateInputs(name: "Valid Name", email: "valid@example.com")
        XCTAssertTrue(isValid)
    }
    
    func testValidateInputsEmptyName() {
        let viewModel = EditProfileViewModel()
        let expectation = XCTestExpectation(description: "Validation empty name")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationFailure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.validationError(RegexMessages.emptyName).localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let isValid = viewModel.validateInputs(name: "", email: "valid@example.com")
        XCTAssertFalse(isValid)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testValidateInputsEmptyEmail() {
        let viewModel = EditProfileViewModel()
        let expectation = XCTestExpectation(description: "Validation empty email")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationFailure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.validationError(RegexMessages.emptyEmail).localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let isValid = viewModel.validateInputs(name: "Valid Name", email: "")
        XCTAssertFalse(isValid)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testValidateInputsInvalidEmail() {
        let viewModel = EditProfileViewModel()
        let expectation = XCTestExpectation(description: "Validation invalid email")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationFailure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.validationError(RegexMessages.invalidEmail).localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let isValid = viewModel.validateInputs(name: "Valid Name", email: "invalid-email")
        XCTAssertFalse(isValid)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Retry Mechanism Tests
    
    func testRetryEditProfile() {
        let mockService = MockAuthService()
        var callCount = 0
        
        mockService.completeProfilePublisher = Deferred {
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
        
        let viewModel = EditProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Retry edit profile")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure = state {
                    viewModel.retryEditProfile()
                    expectation.fulfill()
                } else if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let testImage = UIImage(systemName: "person.circle")!
        viewModel.completeProfleAPI(
            name: "Test User",
            email: "test@example.com",
            needImageUpdate: true,
            image: testImage
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRecentInputsCaching() {
        let viewModel = EditProfileViewModel()
        let testImage = UIImage(systemName: "person.circle")!
        
        viewModel.completeProfleAPI(
            name: "Test User",
            email: "test@example.com",
            needImageUpdate: true,
            image: testImage
        )
        
        XCTAssertEqual(viewModel.recentInputs?.name, "Test User")
        XCTAssertEqual(viewModel.recentInputs?.email, "test@example.com")
        XCTAssertEqual(viewModel.recentInputs?.needImageUpdate, true)
        XCTAssertNotNil(viewModel.recentInputs?.image)
    }
}
