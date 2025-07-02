//
//  SubCatViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class SubCatViewModelTests: XCTestCase {
    
    private var viewModel: SubCatViewModel!
    private var mockService: MockProductService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockProductService()
        viewModel = SubCatViewModel(networkService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testSubCatProductSuccess() {
        
        let response = SubCatProductModal(success: true, code: 200, message: nil, body: nil)
        mockService.subCatProductPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Subcategory success")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if state == .subCatProductSuccess {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.subCatProduct(cateogyID: "123")
        
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.modal?.count, 1)
        XCTAssertEqual(viewModel.displayItems.count, 1)
        XCTAssertEqual(viewModel.displayItems.first?.name, "Product A")
    }

    func testSubCatProductFailure() {
        mockService.subCatProductPublisher = Fail(error: .networkError("Failed"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Subcategory failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .subCatProductFailure(let error) = state {
                    XCTAssertEqual(error, .networkError("Failed"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.subCatProduct(cateogyID: "123")
        wait(for: [expectation], timeout: 2)
    }

    func testLatestProductSuccess() {
        
        let response = LatestProModal(success: true, code: 200, message: nil, body: nil)
        mockService.getLatestProductAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Latest products success")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if state == .getLatestProductSuccess {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.getLatestProductAPI()
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.latestModal?.count, 1)
        XCTAssertEqual(viewModel.displayItems.first?.name, "Latest")
    }

    func testSimilarProductFailure() {
        mockService.getSimilarProductAPIPublisher = Fail(error: .invalidResponse)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Similar product failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .getSimilarProductFailure(let error) = state, error == .invalidResponse {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.getSimilarProductAPI(id: "P100")
        wait(for: [expectation], timeout: 2)
    }

    func testAddToCartAuthError() {
        Store.authToken = nil  // unauthenticated
        viewModel.check = 1
        

        let expectation = expectation(description: "Auth error on add to cart")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if state == .authError {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.addProductToCart(at: 0)
        wait(for: [expectation], timeout: 1)
    }

    func testAddToCartSuccess() {
        Store.authToken = "valid_token"
        viewModel.check = 1

        let response = AddShoppingModal(success: true, code: 200, message: "Added",body: nil)
        mockService.addShoppingAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Add to cart success")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if state == .addShoppingSuccess {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.addProductToCart(at: 0)
        wait(for: [expectation], timeout: 2)
    }
}

