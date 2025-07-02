//
//  SearchCatViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class SearchCatViewModelTests: XCTestCase {

    private var viewModel: SearchCatViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = SearchCatViewModel(networkService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testPerformSearchSuccess() {
        let body = [CreateModalBody]()
        let response = CreateModal(success: true, code: 200, message: "OK", body: body)
        mockService.performSearchPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Search success")

        viewModel.updateSearchQuery("test")
        viewModel.performSearch()

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .searchCreateAPISuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2.0)
    }

    func testPerformSearchFailure() {
        mockService.performSearchPublisher = Fail(error: NetworkError.networkError("Failed"))
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Search failure")

        viewModel.updateSearchQuery("test")
        viewModel.performSearch()

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .searchCreateAPIFailure(let error) = state, error == NetworkError.networkError("Failed") {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2.0)
    }

    func testRecentSearchSuccess() {
        let body = [RecentSearchModalBody]()
        let response = RecentSearchModal(success: true, code: 200, message: "OK", body: body)
        mockService.recentSearchAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Recent search success")

        viewModel.recentSearchAPI()

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .recentSearchAPISuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2.0)
    }

    func testHistoryDeleteSuccess() {
        let response = SearchHistoryDeleteModal(success: true, code: 200, message: "Deleted", body: nil)
        mockService.historyDeleteAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Delete history success")

        viewModel.historyDeleteAPI(with: "123")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .historyDeleteAPISuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2.0)
    }

    func testClearCategory() {
        viewModel.clearCategory()
        XCTAssertEqual(viewModel.category?.count, 0)
    }

}

