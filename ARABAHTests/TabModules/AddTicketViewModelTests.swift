//
//  AddTicketViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class AddTicketViewModelTests: XCTestCase {

    private var viewModel: AddTicketViewModel!
    private var mockService: MockNotesService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockNotesService()
        viewModel = AddTicketViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func test_submitTicket_success() {
        let expectation = XCTestExpectation(description: "Ticket submitted successfully")

        let mockResponse = ReportModal(success: true,code: 200, message: "Ticket submitted",body: nil)
        mockService.addTicketAPIPublisher = Just(mockResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$state
            .dropFirst(2) // loading → success
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected success state, got \(state)")
                }
            }
            .store(in: &cancellables)

        viewModel.submitTicket(title: "Issue Title", description: "Something is wrong")
        wait(for: [expectation], timeout: 1.0)
    }

    func test_submitTicket_failure() {
        let expectation = XCTestExpectation(description: "Ticket submission failed")

        mockService.addTicketAPIPublisher = Fail(error: .networkError("Server unavailable"))
            .eraseToAnyPublisher()

        viewModel.$state
            .dropFirst(2) // loading → failure
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .networkError("Server unavailable"))
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure state, got \(state)")
                }
            }
            .store(in: &cancellables)

        viewModel.submitTicket(title: "Bug", description: "Crash issue")
        wait(for: [expectation], timeout: 1.0)
    }

    func test_submitTicket_emptyTitle_validationError() {
        let expectation = XCTestExpectation(description: "Validation error for empty title")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validateError(let error) = state {
                    XCTAssertEqual(error, .badRequest(message: RegexMessages.emptytittle))
                    expectation.fulfill()
                } else {
                    XCTFail("Expected validation error for empty title")
                }
            }
            .store(in: &cancellables)

        viewModel.submitTicket(title: "", description: "Valid desc")
        wait(for: [expectation], timeout: 1.0)
    }

    func test_submitTicket_emptyDescription_validationError() {
        let expectation = XCTestExpectation(description: "Validation error for empty description")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validateError(let error) = state {
                    XCTAssertEqual(error, .badRequest(message: RegexMessages.emptyDescription))
                    expectation.fulfill()
                } else {
                    XCTFail("Expected validation error for empty description")
                }
            }
            .store(in: &cancellables)

        viewModel.submitTicket(title: "Valid Title", description: "")
        wait(for: [expectation], timeout: 1.0)
    }

    func test_retryLastSubmission_successfulRetry() {
        let expectation = XCTestExpectation(description: "Retry submission succeeds")

        let response = ReportModal(success: true,code: 200, message: "Retried and submitted",body: nil)
        mockService.addTicketAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.submitTicket(title: "Need help", description: "Something failed")

        // retryInputs should now be set; simulate retry
        viewModel.$state
            .dropFirst(3) // idle → loading → success → retry
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.retryLastSubmission()
        wait(for: [expectation], timeout: 1.0)
    }

    func test_retryLastSubmission_noPreviousData_doesNothing() {
        // Ensure nothing crashes or happens when retry is called without a previous input
        viewModel.retryLastSubmission()
        XCTAssertEqual(viewModel.state, .idle)
    }
}

