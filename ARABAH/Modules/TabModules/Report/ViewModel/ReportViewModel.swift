//
//  ReportViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for validating and sending product reports to the backend API.
final class ReportViewModel {

    // MARK: - Input & Output

    /// Struct representing the input required for reporting a product.
    struct Input {
        let productID: String       // Unique identifier of the product being reported.
        let message: String         // User-provided message describing the issue.
    }
    
    /// Enum representing different states of the ViewModel during the report API flow.
    enum State: Equatable {
        case idle                               // Initial/default state.
        case loading                            // API call is in progress.
        case success                            // API call was successful.
        case validateError(NetworkError)        // Input validation failed with specific error.
        case failure(NetworkError)              // API call failed with error.
    }
    
    // MARK: - Properties

    /// Published property to expose current state changes to the ViewController.
    @Published private(set) var state: State = .idle

    /// Container to hold Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Network service responsible for performing API requests.
    private let networkService: ProductServicesProtocol

    // MARK: - Initialization

    /// Initializes the ReportViewModel with a network service.
    /// - Parameter networkService: Dependency conforming to `ProductServicesProtocol` (default is `ProductServices()`).
    init(networkService: ProductServicesProtocol = ProductServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods

    /// Calls the report API after validating the input.
    /// - Parameter input: The input containing `productID` and `message`.
    func reportAPI(with input: Input) {
        // Trim unnecessary whitespace from the message.
        let trimmedMessage = input.message.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate the cleaned message.
        guard validateInputs(description: trimmedMessage) else {
            return
        }

        // Set state to loading before making the network request.
        state = .loading

        // Perform the API call using the provided network service.
        networkService.reportAPI(productID: input.productID, message: trimmedMessage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle failure case from the Combine pipeline.
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (_: ReportModal) in
                // Set state to success when API call completes with data.
                self?.state = .success
            }
            .store(in: &cancellables) // Store the subscription to manage lifecycle.
    }
    
    // MARK: - Validation

    /// Validates the user input message.
    /// - Parameter description: The trimmed message string to validate.
    /// - Returns: A boolean indicating if the input is valid.
    private func validateInputs(description: String) -> Bool {
        // Check if message is empty.
        if description.isEmpty {
            // Set validation error state with a descriptive error.
            state = .validateError(.badRequest(message: RegexMessages.invalidEmptyDescription))
            return false
        }
        return true
    }
}
