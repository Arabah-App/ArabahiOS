//
//  LoginViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import Foundation
import Combine

/// ViewModel responsible for handling login logic via phone number and country code.
final class LoginViewModel {
    
    // MARK: -  Output
    /// Enum representing various possible UI states during login flow.
    enum State {
        case idle                         // Default state, no operation
        case loading                      // Login in progress
        case success(LoginModal)         // Login succeeded with response
        case failure(NetworkError)       // Login failed with error
        case validatefailure(NetworkError)       // Validatation failed with error
    }
    
    // MARK: - Properties
    
    /// Published state observable by UI
    @Published private(set) var state: State = .idle
    
    private var cancellables = Set<AnyCancellable>()              // To hold Combine subscriptions
    private let authServices: AuthServicesProtocol                // API service for login
    private var previousInput: (countryCode: String, phoneNumber: String)?  // Store last login attempt for retry

    // MARK: - Initialization
    
    /// Initializes the ViewModel with an optional custom auth service
    init(authServices: AuthServicesProtocol = AuthServices()) {
        self.authServices = authServices
    }
    
    // MARK: - Public Methods
    
    /// Performs login using country code and phone number.
    func login(countryCode: String, phoneNumber: String)  {
        // Save input for retry
        self.previousInput = (countryCode, phoneNumber)
        
        // Validate input before proceeding
        guard validateInputs(countryCode: countryCode, phoneNumber: phoneNumber) else {
            return
        }
        
        // Notify UI that loading has started
        state = .loading
        
        // Call API to login
        authServices.loginUser(countryCode: countryCode, phoneNumber: phoneNumber)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle error
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: LoginModal) in
                // On success, store data and update state
                Store.authToken = response.body?.authToken
                Store.userDetails = response
                self?.state = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retry login using the previously stored input
    func retryLogin() {
        if let input = previousInput {
            state = .idle
            login(countryCode: input.countryCode, phoneNumber: input.phoneNumber)
        }
    }
    
    // MARK: - Validation
    
    /// Validates the login input values before making the API request.
    private func validateInputs(countryCode: String, phoneNumber: String) -> Bool {
        // Check if country code is present
        guard !countryCode.isEmpty else {
            state = .validatefailure(.validationError(RegexMessages.invalidCountryCode))
            return false
        }
        
        // Check if phone number is present
        guard !phoneNumber.isEmpty else {
            state = .validatefailure(.validationError(RegexMessages.emptyPhoneNumber))
            return false
        }
        
        // Validate minimum phone number length
        guard phoneNumber.count >= 8 else {
            state = .validatefailure(.validationError(RegexMessages.invalidPhoneNumber))
            return false
        }
        
        return true
    }
}
