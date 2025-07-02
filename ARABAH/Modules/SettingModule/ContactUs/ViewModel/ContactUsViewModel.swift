//
//  ContactUsViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

final class ContactUsViewModel {
    
    // MARK: - Output
    
    /// Represents the different UI states for the Contact Us screen
    enum State {
        case idle                    // Initial or reset state
        case loading                 // When API request is in progress
        case success(ContactUsModal) // When API responds successfully
        case failure(NetworkError)   // When API fails with an error
        case validationFailure(NetworkError)   // validation with an error
    }
    
    // MARK: - Properties
    
    /// Published property to notify the view of state changes
    @Published private(set) var state: State = .idle
    
    /// Set to manage Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Service instance to make API calls
    private let settingsServices: SettingsServicesProtocol
    
    /// Stores previous input params for retry in case of failure
    var previousParams: (name: String, email: String, message: String)?
    
    // MARK: - Initialization
    
    /// Initializes the view model with a dependency-injected service
    init(settingsServices: SettingsServicesProtocol = SettingsServices()) {
        self.settingsServices = settingsServices
    }
    
    // MARK: - Public Methods
    
    /// Triggers the Contact Us API call
    /// - Parameters:
    ///   - name: User's name
    ///   - email: User's email
    ///   - message: Message to be sent
    func contactUsAPI(name: String, email: String, message: String) {
        // Store input for potential retry
        self.previousParams = (name: name, email: email, message: message)
        
        // Validate input before proceeding
        guard validateInputs(firstName: name, email: email, message: message) else {
            return
        }
        
        state = .loading
        
        // Make the API call using the service layer
        settingsServices.contactUsAPI(name: name, email: email, message: message)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle failure case
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: ContactUsModal) in
                // Handle successful API response
                self?.state = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retries the Contact Us API using previously entered parameters
    func retryContactUs() {
        if let inputs = self.previousParams {
            state = .idle
            self.contactUsAPI(name: inputs.name, email: inputs.email, message: inputs.message)
        }
    }
    
    /// Validates user input fields before making the API call
    /// - Returns: `true` if all fields are valid, otherwise `false`
    private func validateInputs(firstName: String, email: String, message: String) -> Bool {
        if firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            state = .validationFailure(.validationError(RegexMessages.emptyName))
            return false
        } else if email.trimmingCharacters(in: .whitespaces).isEmpty {
            state = .validationFailure(.validationError(RegexMessages.emptyEmail))
            return false
        } else if !Validation().validateEmailId(emailID: email) {
            state = .validationFailure(.validationError(RegexMessages.invalidEmail))
            return false
        } else if message.trimmingCharacters(in: .whitespaces).isEmpty {
            state = .validationFailure(.validationError(RegexMessages.emptyMessage))
            return false
        }
        return true
    }
}
