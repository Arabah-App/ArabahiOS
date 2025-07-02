//
//  LoginViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 04/06/25.
//

import XCTest
import Combine
@testable import ARABAH

final class LoginViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    func testLoginSuccess() {
        let mockService = MockAuthService()
        
        mockService.loginUserPublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil)
        ).setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let viewModel = LoginViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Login success")

        viewModel.$state
            .dropFirst() // skip .idle
            .sink { state in
                if case .success(let response) = state {
                    XCTAssertEqual(response.body?.authToken, "123")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login(countryCode: "+1", phoneNumber: "12345678")
        wait(for: [expectation], timeout: 2.0)
    }

    func testLoginFailure() {
        let mockService = MockAuthService()
        mockService.loginUserPublisher = Fail(error: NetworkError.badRequest(message: "Invalid phone")).eraseToAnyPublisher()

        let viewModel = LoginViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Login fails")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, "Invalid phone")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login(countryCode: "+1", phoneNumber: "12345678")
        wait(for: [expectation], timeout: 2.0)
    }
}

