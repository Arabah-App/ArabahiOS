//
//  ReportViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class ReportViewModelTests: XCTestCase {
    
    private var viewModel: ReportViewModel!
    private var mockService: MockProductService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockProductService()
        viewModel = ReportViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testReportSuccess() {
        // Arrange
        let mockResponse = ReportModal(success: true, code: 200, message: "Reported",body: nil)
        mockService.reportAPIPublisher = Just(mockResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should emit .success")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if state == .success {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.reportAPI(with: .init(productID: "123", message: "This is inappropriate"))

        // Assert
        wait(for: [expectation], timeout: 2)
    }

    func testReportValidationFailure() {
        // Arrange
        let expectation = expectation(description: "Should emit .validateError")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validateError(let error) = state {
                    XCTAssertEqual(error, .badRequest(message: RegexMessages.invalidEmptyDescription))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.reportAPI(with: .init(productID: "123", message: "   ")) // only whitespace

        // Assert
        wait(for: [expectation], timeout: 1)
    }

    func testReportFailure() {
        // Arrange
        mockService.reportAPIPublisher = Fail(error: .networkError("Something went wrong"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should emit .failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .networkError("Something went wrong"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.reportAPI(with: .init(productID: "123", message: "Report content"))

        // Assert
        wait(for: [expectation], timeout: 2)
    }
}

