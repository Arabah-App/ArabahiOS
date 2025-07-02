//
//  ShoppingListViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class ShoppingListViewModelTests: XCTestCase {

    private var viewModel: ShoppingListViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = ShoppingListViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testShoppingListDeleteAPISuccess() {
        let deleteModal = shoppinglistDeleteModal(success: true, code: 200, message: "Deleted",body: nil)
        mockService.shoppingListDeleteAPIPublisher = Just(deleteModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Delete API call succeeds")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .listDeleteSuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListDeleteAPI(id: "123")

        wait(for: [expectation], timeout: 1.0)
    }

    func testShoppingListDeleteAPIFailure() {
        mockService.shoppingListDeleteAPIPublisher = Fail(error: .serverError(message: "Delete Failed"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Delete API call fails")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .listDeleteFailure(let error) = state {
                    XCTAssertEqual(error, .serverError(message: "Delete Failed"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListDeleteAPI(id: "456")

        wait(for: [expectation], timeout: 1.0)
    }

    func testRetryListDeleteAPI() {
        let deleteModal = shoppinglistDeleteModal(success: true, code: 200, message: "Deleted", body: nil)
        mockService.shoppingListDeleteAPIPublisher = Just(deleteModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Retry Delete API call succeeds")

        viewModel.$state
            .dropFirst(2)
            .sink { state in
                if case .listDeleteSuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListDeleteAPI(id: "789")
        viewModel.retryListDeleteAPI()

        wait(for: [expectation], timeout: 1.0)
    }

    func testShoppingListClearAllAPISuccess() {
        let clearModal = CommentModal(productID: "", comment: "", userID: "", deleted: false, id: "", createdAt: "", updatedAt: "", v: 0)
        mockService.shoppingListClearAllAPIPublisher = Just(clearModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Clear All API call succeeds")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .listClearSuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListClearAllAPI()

        wait(for: [expectation], timeout: 1.0)
    }

    func testShoppingListClearAllAPIFailure() {
        mockService.shoppingListClearAllAPIPublisher = Fail(error: .serverError(message: "Clear Failed"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Clear All API call fails")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .listClearFailure(let error) = state {
                    XCTAssertEqual(error, .serverError(message: "Clear Failed"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListClearAllAPI()

        wait(for: [expectation], timeout: 1.0)
    }

    func testRetryShoppingListClearAllAPI() {
        let clearModal = CommentModal(productID: "", comment: "", userID: "", deleted: false, id: "", createdAt: "", updatedAt: "", v: 0)
        mockService.shoppingListClearAllAPIPublisher = Just(clearModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Retry Clear All API call succeeds")

        viewModel.$state
            .dropFirst(2)
            .sink { state in
                if case .listClearSuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListClearAllAPI()
        viewModel.retryShoppingListClearAllAPI()

        wait(for: [expectation], timeout: 1.0)
    }
}
