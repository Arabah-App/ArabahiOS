//
//  VerificationViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class VerificationViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Verify OTP Tests
    
    func testVerifyOTPSuccess() {
        let mockService = MockAuthService()
        let expectedToken = "test_token_123"
        
        mockService.verifyOTPPublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil)
        ).setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = VerificationViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "OTP verification success")
        
        viewModel.$state
            .dropFirst() // skip initial .idle state
            .sink { state in
                if case .verificationSuccess = state {
                    XCTAssertEqual(Store.authToken, expectedToken)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.verifyOTP(otp: "1234", phoneNumberWithCode: "+123456789")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testVerifyOTPFailure() {
        let mockService = MockAuthService()
        let expectedError = NetworkError.badRequest(message: "Invalid OTP")
        
        mockService.verifyOTPPublisher = Fail(error: expectedError)
            .eraseToAnyPublisher()
        
        let viewModel = VerificationViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "OTP verification failure")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.verifyOTP(otp: "1234", phoneNumberWithCode: "+123456789")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testVerifyOTPValidationFailure() {
        let mockService = MockAuthService()
        let viewModel = VerificationViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "OTP validation failure")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationFailure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.validationError(RegexMessages.enterOTP).localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.verifyOTP(otp: "123", phoneNumberWithCode: "+123456789") // OTP too short
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Resend OTP Tests
    
    func testResendOTPSuccess() {
        let mockService = MockAuthService()
        
        mockService.resendOTPPublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil)
        ).setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = VerificationViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Resend OTP success")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .resendSuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.resendOTP(phoneNumberWithCode: "+123456789")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testResendOTPFailure() {
        let mockService = MockAuthService()
        let expectedError = NetworkError.badRequest(message: "Rate limited")
        
        mockService.resendOTPPublisher = Fail(error: expectedError)
            .eraseToAnyPublisher()
        
        let viewModel = VerificationViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Resend OTP failure")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .resendFailure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.resendOTP(phoneNumberWithCode: "+123456789")
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Retry Tests
    
    func testRetryVerifyOTP() {
        let mockService = MockAuthService()
        let expectedToken = "retry_token"
        var callCount = 0
        
        mockService.verifyOTPPublisher = Deferred {
            Future<LoginModal, NetworkError> { promise in
                callCount += 1
                if callCount == 1 {
                    promise(.failure(.badRequest(message: "First failure")))
                } else {
                    promise(.success(LoginModal(
                        success: true,
                        code: 200,
                        message: "Success",
                        body: nil)
                    ))
                }
            }
        }.eraseToAnyPublisher()
        
        let viewModel = VerificationViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Retry verify OTP")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure = state {
                    viewModel.retryVerifyOTP()
                    expectation.fulfill()
                } else if case .verificationSuccess = state {
                    XCTAssertEqual(Store.authToken, expectedToken)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.verifyOTP(otp: "1234", phoneNumberWithCode: "+123456789")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetryResendOTP() {
        let mockService = MockAuthService()
        var callCount = 0
        
        mockService.resendOTPPublisher = Deferred {
            Future<LoginModal, NetworkError> { promise in
                callCount += 1
                if callCount == 1 {
                    promise(.failure(.badRequest(message: "First failure")))
                } else {
                    promise(.success(LoginModal(
                        success: true,
                        code: 200,
                        message: "Success",
                        body: nil)
                    ))
                }
            }
        }.eraseToAnyPublisher()
        
        let viewModel = VerificationViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Retry resend OTP")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .resendFailure = state {
                    viewModel.retryResendOTP()
                    expectation.fulfill()
                } else if case .resendSuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.resendOTP(phoneNumberWithCode: "+123456789")
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Input Caching Tests
    
    func testPreviousInputCaching() {
        let mockService = MockAuthService()
        let viewModel = VerificationViewModel(authServices: mockService)
        
        let testOTP = "1234"
        let testPhone = "+123456789"
        
        viewModel.verifyOTP(otp: testOTP, phoneNumberWithCode: testPhone)
        
        XCTAssertEqual(viewModel.previousInput?.otp, testOTP)
        XCTAssertEqual(viewModel.previousInput?.phoneNnumberWithCode, testPhone)
    }
    
    func testPreviousResendInputCaching() {
        let mockService = MockAuthService()
        let viewModel = VerificationViewModel(authServices: mockService)
        
        let testPhone = "+123456789"
        
        viewModel.resendOTP(phoneNumberWithCode: testPhone)
        
        XCTAssertEqual(viewModel.previousResendInput, testPhone)
    }
    
    // MARK: - NetworkError Extension Test
    
    func testShouldClearOTPFields() {
        let error1 = NetworkError.badRequest(message: PlaceHolderTitleRegex.PleaseEnterValidOTP)
        XCTAssertTrue(error1.shouldClearOTPFields)
        
        let error2 = NetworkError.badRequest(message: PlaceHolderTitleRegex.PleaseEnterValidOTPAR)
        XCTAssertTrue(error2.shouldClearOTPFields)
        
        let error3 = NetworkError.badRequest(message: PlaceHolderTitleRegex.apiFailTryAgain)
        XCTAssertTrue(error3.shouldClearOTPFields)
        
        let error4 = NetworkError.badRequest(message: "Some other error")
        XCTAssertFalse(error4.shouldClearOTPFields)
        
        let error5 = NetworkError.unauthorized
        XCTAssertFalse(error5.shouldClearOTPFields)
    }
}

