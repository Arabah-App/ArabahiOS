//
//  HomeViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//


import XCTest
import Combine
import CoreLocation
@testable import ARABAH

final class HomeViewModelTests: XCTestCase {
    
    private var viewModel: HomeViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = HomeViewModel(homeServices: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Success Response
    
    func testFetchHomeDataSuccess() {
        // Given
       
        let modal = HomeModal(success: true, code: 200, message: "Success", body: nil)
        
        mockService.homeListAPIPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = self.expectation(description: "Home data success")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchHomeData(longitude: "77.1", latitude: "28.6")
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.banner.count, 1)
        XCTAssertEqual(viewModel.category.count, 1)
        XCTAssertEqual(viewModel.latProduct.count, 1)
    }
    
    // MARK: - Test Failure Response
    
    func testFetchHomeDataFailure() {
        // Given
        mockService.homeListAPIPublisher = Fail(error: NetworkError.networkError("No internet"))
            .eraseToAnyPublisher()
        
        let expectation = self.expectation(description: "Home data failure")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.networkError("No internet").localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchHomeData(longitude: "77.1", latitude: "28.6")
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(viewModel.banner.isEmpty)
        XCTAssertTrue(viewModel.category.isEmpty)
        XCTAssertTrue(viewModel.latProduct.isEmpty)
    }
    
    // MARK: - Test Retry
    
    func testRetryHomeAPIAfterFailure() {
        // 1. Trigger failure
        mockService.homeListAPIPublisher = Fail(error: NetworkError.networkError("No internet"))
            .eraseToAnyPublisher()
        viewModel.fetchHomeData(longitude: "77.1", latitude: "28.6", categoryID: "1", categoryName: "Test")
        
        // 2. Change mock to success
    
        let successModal = HomeModal(success: true, code: 200, message: "OK", body: nil)
        
        mockService.homeListAPIPublisher = Just(successModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = self.expectation(description: "Retry success")
        
        // Observe state
        viewModel.$state
            .dropFirst(2) // Skip loading and failure
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Retry
        viewModel.retryHomeAPI()
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.banner.count, 1)
        XCTAssertEqual(viewModel.category.count, 1)
        XCTAssertEqual(viewModel.latProduct.count, 1)
    }
    
    // MARK: - Test Update Location

    func testUpdateLocationTriggersFetch() {
        // Given
        
        let successModal = HomeModal(success: true, code: 200, message: "OK", body: nil)
        
        mockService.homeListAPIPublisher = Just(successModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = self.expectation(description: "Location triggers fetch")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        let location = CLLocationCoordinate2D(latitude: 28.6, longitude: 77.1)
        viewModel.updateLocation(location)
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.location?.latitude, 28.6)
        XCTAssertEqual(viewModel.location?.longitude, 77.1)
    }
}

