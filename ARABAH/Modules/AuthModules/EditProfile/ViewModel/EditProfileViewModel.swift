//
//  EditProfileViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for handling profile editing logic.
final class EditProfileViewModel {
    
    // MARK: - Output
    
    /// Represents the different states the ViewModel can emit to the UI.
    enum State {
        case idle                          // No action yet
        case loading                       // API request in progress
        case success(LoginModal)          // Profile update successful
        case failure(NetworkError)        // Profile update failed
        case validationFailure(NetworkError)        // Profile validation failed
    }
    
    // MARK: - Properties
    
    /// Publishes changes in state so the UI can react accordingly.
    @Published private(set) var state: State = .idle
    
    /// Used to store Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    /// API service for authentication/profile-related requests.
    private let authServices: AuthServicesProtocol
    
    /// Holds the most recent input so we can retry if needed.
     var recentInputs: (name: String, email: String, needImageUpdate: Bool, image: UIImage)?
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with a default or custom AuthService.
    init(authServices: AuthServicesProtocol = AuthServices()) {
        self.authServices = authServices
    }
    
    // MARK: - Public Methods
    
    /// Triggers the API call to update the user profile.
    /// - Parameters:
    ///   - name: User's name
    ///   - email: User's email
    ///   - needImageUpdate: Flag indicating if the image was changed
    ///   - image: Updated profile image
    func completeProfleAPI(name: String, email: String, needImageUpdate: Bool, image: UIImage) {
        // Store the inputs in case we need to retry
        self.recentInputs = (name: name, email: email, needImageUpdate: needImageUpdate, image: image)
        
        // Validate name and email before proceeding
        guard validateInputs(name: name, email: email) else {
            return
        }
        
        // Notify UI that loading has started
        state = .loading
        
        // Call the profile update API
        authServices.completeProfile(name: name, email: email, needImageUpdate: needImageUpdate, image: image)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle API failure
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: LoginModal) in
                // On success, update user data and notify UI
                Store.userDetails = response
                self?.state = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retries the last profile update request, using the last known input.
    func retryEditProfile() {
        if let inputs = self.recentInputs {
            state = .idle
            self.completeProfleAPI(
                name: inputs.name,
                email: inputs.email,
                needImageUpdate: inputs.needImageUpdate,
                image: inputs.image
            )
        }
    }
    
    /// Validates user input before sending it to the server.
    /// - Parameters:
    ///   - name: The user's name
    ///   - email: The user's email
    /// - Returns: Boolean indicating whether the inputs are valid
    func validateInputs(name: String, email: String) -> Bool {
        // Name shouldn't be empty
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            state = .validationFailure(.validationError(RegexMessages.emptyName))
            return false
            
        // Email shouldn't be empty
        } else if email.trimmingCharacters(in: .whitespaces).isEmpty {
            state = .validationFailure(.validationError(RegexMessages.emptyEmail))
            return false
            
        // Email should be in a valid format
        } else if !Validation().validateEmailId(emailID: email) {
            state = .validationFailure(.validationError(RegexMessages.invalidEmail))
            return false
        }
        
        // All inputs are valid
        return true
    }
}
