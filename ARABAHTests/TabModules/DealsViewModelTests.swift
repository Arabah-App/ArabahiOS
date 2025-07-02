//
//  DealsViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class DealsViewModelTests: XCTestCase {

    var viewModel: DealsViewModel!
    var mockService: MockHomeService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = DealsViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testGetOfferDealsAPISuccess_shouldUpdateDealsAndSetSuccessState() {
        // Given


        let response = GetOfferDealsModal(success: true, code: 200, message: "OK", body: nil)

        mockService.getOfferDealsAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "State becomes success")

        viewModel.$state
            .dropFirst() // skip .idle
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.getOfferDealsAPI()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.dealsBody?.count, 1)
        XCTAssertEqual(viewModel.dealsBody?.first?.decription, "Big Sale")
    }

    func testGetOfferDealsAPIFailure_shouldSetFailureState() {
        // Given
        mockService.getOfferDealsAPIPublisher = Fail(error: NetworkError.serverError(message: "API failed"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "State becomes failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state, error == NetworkError.serverError(message: "API failed") {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.getOfferDealsAPI()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    func testIsPDF_shouldReturnCorrectResult() {
        XCTAssertTrue(viewModel.isPDF("http://domain.com/file.pdf"))
        XCTAssertFalse(viewModel.isPDF("http://domain.com/image.jpg"))
    }

    func testFormattedDealText_shouldReturnExpectedString() {

        let text = viewModel.formattedDealText(at: 0)
        XCTAssertTrue(text.contains("Mart"))
        XCTAssertTrue(text.contains("Save More"))
    }

    func testDealImageUrlAndStoreImageUrl_shouldReturnExpectedURLs() {

        let dealURL = viewModel.dealImageUrl(at: 0)
        let storeURL = viewModel.storeImageUrl(at: 0)

        XCTAssertTrue(dealURL.contains("deal.jpg"))
        XCTAssertTrue(storeURL.contains("store.jpg"))
    }
}
