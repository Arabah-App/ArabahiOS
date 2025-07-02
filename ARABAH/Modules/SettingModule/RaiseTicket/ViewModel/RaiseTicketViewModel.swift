//
//  RaiseTicketViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for managing support ticket fetching logic
final class RaiseTicketViewModel {
    
    // MARK: - State Enum
    
    /// Represents the current state of the ticket API request
    enum State {
        case idle                  // Default state — no action
        case loading               // Indicates API call is in progress
        case success               // Tickets fetched successfully
        case failure(NetworkError) // Tickets failed to fetch due to error
    }
    
    // MARK: - Properties
    
    /// Published property to notify observers about state changes
    @Published private(set) var state: State = .idle
    
    /// Holds the list of support tickets fetched from the server
    @Published private(set) var ticketBody: [getTicketModalBody]? = []
    
    /// Combine cancellables to manage subscription lifecycle
    private var cancellables = Set<AnyCancellable>()
    
    /// Dependency to perform API requests (injected or default)
    private let settingsServices: SettingsServicesProtocol
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with an optional custom service implementation
    init(settingsServices: SettingsServicesProtocol = SettingsServices()) {
        self.settingsServices = settingsServices
    }
    
    // MARK: - Public Methods
    
    /// Calls the API to retrieve the list of support tickets
    func getTicketAPI() {
        // Move to loading state to trigger UI feedback
        state = .loading
        
        // Request tickets via service
        settingsServices.getTicketAPI()
            .receive(on: DispatchQueue.main) // UI updates on main thread
            .sink { [weak self] completion in
                // Handle network or parsing error
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: getTicketModal) in
                // Safely unwrap ticket list from response body
                guard let contentBody = response.body else {
                    self?.state = .failure(.invalidResponse)
                    return
                }
                
                // Store the ticket list and mark success
                self?.ticketBody = contentBody
                self?.state = .success
            }
            .store(in: &cancellables)
    }
    
    /// Retries fetching tickets in case of failure
    func retryGetTicket() {
        // Reset state to idle before retrying
        state = .idle
        self.getTicketAPI()
    }
}
