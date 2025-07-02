//
//  NotificationViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class NotificationViewModelTests: XCTestCase {
    
    private var viewModel: NotificationViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = NotificationViewModel(networkService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test: getNotificationList Success
    
    func testGetNotificationListSuccess() {
        // Given
        
        let modal = GetNotificationModal(success: true, code: 200, message: "ok", body: nil)
        
        mockService.getNotificationListPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Get notification list success")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .getNotificationListSuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getNotificationList()
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.count(), 1)
        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertEqual(viewModel.productID(at: 0), "p1")
    }
    
    // MARK: - Test: getNotificationList Failure
    
    func testGetNotificationListFailure() {
        // Given
        mockService.getNotificationListPublisher = Fail(error: NetworkError.networkError("No internet"))
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Get notification list failure")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .getNotificationListFailure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.networkError("No internet").localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.getNotificationList()
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(viewModel.isEmpty)
    }
    
    // MARK: - Test: notificationDeleteAPI Success
    
    func testNotificationDeleteSuccess() {
        // Given
        let response = NewCommonString(success: true, code: 200, message: "Deleted",body: nil)
        mockService.notificationDeleteAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Notification delete success")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .deleteSuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.notificationDeleteAPI()
        
        // Then
        wait(for: [expectation], timeout: 2)
    }
    
    // MARK: - Test: notificationDeleteAPI Failure
    
    func testNotificationDeleteFailure() {
        // Given
        mockService.notificationDeleteAPIPublisher = Fail(error: NetworkError.badRequest(message: "Delete failed"))
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Notification delete failure")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .deleteFailure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.badRequest(message: "Delete failed").localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.notificationDeleteAPI()
        
        // Then
        wait(for: [expectation], timeout: 2)
    }
    
    // MARK: - Test: Retry
    
    func testRetryGetNotificationTriggersFetch() {
        // First trigger a failure
        mockService.getNotificationListPublisher = Fail(error: NetworkError.badRequest(message: "error"))
            .eraseToAnyPublisher()
        viewModel.getNotificationList()
        
        // Set up a success response
    
        let modal = GetNotificationModal(success: true, code: 200, message: "ok", body: nil)
        mockService.getNotificationListPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Retry get notification works")
        
        viewModel.$state
            .dropFirst(2) // skip loading + failure
            .sink { state in
                if case .getNotificationListSuccess = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.retryGetNotification()
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.count(), 1)
    }
}

