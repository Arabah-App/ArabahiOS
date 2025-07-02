//
//  NotificationViewModel.swift
//  ARABAH
//
//  ViewModel handling all notification-related business logic and data
//

import UIKit
import Combine

/// ViewModel responsible for handling notification-related API calls and data management.
final class NotificationViewModel {
    
    // MARK: - State Enum
    // Tracks the current state of view model operations
    enum State {
        case idle                  // Initial state, no operation in progress
        case loading               // API call in progress
        case getNotificationListSuccess  // Successfully fetched notifications
        case deleteSuccess         // Successfully deleted notifications
        case getNotificationListFailure(NetworkError)  // Failed to fetch notifications
        case deleteFailure(NetworkError)  // Failed to delete notifications
    }
    
    // MARK: - Properties
    
    // Published state that views can observe
    @Published private(set) var state: State = .idle
    
    // Collection of notification cell models for the table view
    @Published private(set) var notificationCellModels: [NotificationCellModel] = []

    // Storage for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // Network service for API calls
    private let networkService: HomeServicesProtocol
    
    // Base URL for notification images
    private let imageBaseURL = imageURL
    
    // Language flag for localization
    private let isArabic = Store.isArabicLang
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with optional network service (defaults to HomeServices)
    init(networkService: HomeServicesProtocol = HomeServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Notification List Methods
    
    /// Fetches the list of notifications from the server
    func getNotificationList() {
        // Set loading state before making API call
        state = .loading
        
        networkService.getNotificationList()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            // Handle API completion (failure case)
            if case .failure(let error) = completion {
                self?.state = .getNotificationListFailure(error)
            }
        } receiveValue: { [weak self] (response: GetNotificationModal) in
            // Handle successful API response
            guard let bodies = response.body else {
                self?.state = .getNotificationListFailure(.invalidResponse)
                return
            }
            
            // Convert API response to cell models
            self?.notificationCellModels = bodies.map {
                NotificationCellModel(
                    body: $0,
                    baseURL: self?.imageBaseURL ?? "",
                    isArabic: self?.isArabic ?? false
                )
            }
            
            // Update state to success
            self?.state = .getNotificationListSuccess
        }
        .store(in: &cancellables)
    }
    
    /// Retry mechanism for failed notification list fetch
    func retryGetNotification() {
        state = .idle
        self.getNotificationList()
    }
    
    // MARK: - Notification Deletion Methods
    
    /// Deletes all notifications via API
    func notificationDeleteAPI() {
        state = .loading
        networkService.notificationDeleteAPI()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            // Handle deletion failure
            if case .failure(let error) = completion {
                self?.state = .deleteFailure(error)
            }
        } receiveValue: { [weak self] (_: NewCommonString) in
            // Handle successful deletion
            self?.state = .deleteSuccess
        }
        .store(in: &cancellables)
    }

    /// Retry mechanism for failed deletion
    func retryDeleteNotification() {
        state = .idle
        self.notificationDeleteAPI()
    }
    
    // MARK: - Data Access Methods
    
    /// Returns whether the notification list is empty
    var isEmpty: Bool {
        return notificationCellModels.isEmpty
    }

    /// Returns the notification model at specified index
    func model(at index: Int) -> NotificationCellModel? {
        return notificationCellModels[safe: index]
    }

    /// Returns total count of notifications
    func count() -> Int {
        return notificationCellModels.count
    }

    /// Returns product ID for notification at specified index
    func productID(at index: Int) -> String {
        return notificationCellModels[safe: index]?.productID ?? ""
    }
}
