//
//  FavViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//


import XCTest
import Combine
@testable import ARABAH

final class FavViewModelTests: XCTestCase {

    private var viewModel: FavViewModel!
    private var mockService: MockProductService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockProductService()
        viewModel = FavViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testLikeDislikeSuccessAndFetchList() {
        // Arrange
        let likeModal = LikeModal(success: true, code: 200, message: "Liked",body: nil)
        let response = LikeProductModal(
            success: true,
            code: 200,
            message: "Fetched",
            body: nil
        )

        mockService.likeDislikeAPIPublisher = Just(likeModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        mockService.getProductfavListPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation1 = expectation(description: "LikeDislike Success")
        let expectation2 = expectation(description: "Fav List Success")

        var receivedStates: [FavViewModel.State] = []

        viewModel.$state
            .dropFirst()
            .sink { state in
                receivedStates.append(state)
                if state == .likeDisLikeSuccess {
                    expectation1.fulfill()
                }
                if state == .likedListSuccess {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.likeDislikeAPI(productID: "123")

        // Assert
        wait(for: [expectation1, expectation2], timeout: 2)
        XCTAssertEqual(receivedStates.first, .loading)
        XCTAssertEqual(viewModel.likedBody?.count, 1)
        XCTAssertEqual(viewModel.likedBody?.first?.productID?.name, "Test Product")
        XCTAssertFalse(viewModel.showNoDataMessage)
    }

    func testLikeDislikeFailure() {
        // Arrange
        mockService.likeDislikeAPIPublisher = Fail(error: NetworkError.networkError("Failed"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "LikeDislike Failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .likeDisLikeFailure(let error) = state {
                    XCTAssertEqual(error, .networkError("Failed"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.likeDislikeAPI(productID: "123")

        // Assert
        wait(for: [expectation], timeout: 2)
    }

    func testGetProductfavListSuccessWithEmptyData() {
        // Arrange
        let emptyResponse = LikeProductModal(success: true, code: 200, message: "Empty", body: [])

        mockService.getProductfavListPublisher = Just(emptyResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Fetch Fav List Empty")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if state == .likedListSuccess {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.getProductfavList()

        // Assert
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(viewModel.likedBody?.isEmpty ?? false)
        XCTAssertTrue(viewModel.showNoDataMessage)
    }

    func testGetProductfavListFailure() {
        // Arrange
        mockService.getProductfavListPublisher = Fail(error: NetworkError.invalidResponse)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Fetch Fav List Failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .likedListFailure(let error) = state {
                    XCTAssertEqual(error, .invalidResponse)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.getProductfavList()

        // Assert
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(viewModel.likedBody?.isEmpty ?? false)
        XCTAssertTrue(viewModel.showNoDataMessage)
    }
}

