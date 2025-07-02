//
//  CategoryViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class CategoryViewModelTests: XCTestCase {
    
    private var viewModel: CategoryViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = CategoryViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchCategoriesSuccess() {
        // Given
        
        let mockBody = CategoryListModal(success: true, code: 200, message: "OK", body: nil)
        mockService.fetchCategoriesPublisher = Just(mockBody)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "State should be success")

        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.latitude = "25.0"
        viewModel.longitude = "55.0"
        viewModel.fetchCategories()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.numberOfItems, 1)
        XCTAssertFalse(viewModel.isEmpty)
    }

    func testFetchCategoriesFailure() {
        // Given
        mockService.fetchCategoriesPublisher = Fail(error: NetworkError.serverError(message: "Internal error"))
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "State should be failure")

        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .serverError(message: "Internal error"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.latitude = "25.0"
        viewModel.longitude = "55.0"
        viewModel.fetchCategories()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.numberOfItems, 0)
        XCTAssertTrue(viewModel.isEmpty)
    }

    func testRetryTriggersFetch() {
        // Given
        
        let mockBody = CategoryListModal(success: true, code: 200, message: "OK", body: nil)
        mockService.fetchCategoriesPublisher = Just(mockBody)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Retry should succeed")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.latitude = "24.0"
        viewModel.longitude = "54.0"
        viewModel.retry()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.numberOfItems, 1)
    }

    func testCategoryCellAccess() {
        // Given
        
        //viewModel.categoryBody = [CategoryListModalBody.init(category: nil)]

        // When
        let result = viewModel.categoryCell(for: 0)

        // Then
        XCTAssertEqual(result?.id, "10")
        XCTAssertEqual(viewModel.numberOfItems, 1)
    }
}

