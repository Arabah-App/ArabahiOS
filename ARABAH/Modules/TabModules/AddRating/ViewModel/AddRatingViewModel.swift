import UIKit
import Combine

/// Handles submitting and validating product ratings and reviews
final class AddRatingViewModel {
    
    // MARK: - Inputs / Output
    
    // Bundles all the data needed to submit a review
    struct Inputs {
        var productId: String  // The product being reviewed
        var rating: Double     // Star rating (e.g. 4.5)
        var review: String    // Written review text
    }
    
    // Tracks the current state of review submission
    enum State : Equatable {
        case idle       // Ready for input
        case loading   // Currently submitting review
        case success   // Review submitted successfully
        case failure(NetworkError)  // Submission failed with error
        case validationFailure(NetworkError)  // Validation failed with error
    }
    
    // MARK: - Properties
    
    // Current state that views can observe
    @Published private(set) var state: State = .idle
    
    // Stores Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // Handles network requests for product services
    private let networkService: ProductServicesProtocol
    
    // Stores the last submission attempt for retry functionality
    private var lastInputs: Inputs?
    
    // MARK: - Initialization
    
    /// Creates a new AddRatingViewModel
    /// - Parameter networkService: Service for product-related network calls (defaults to ProductServices)
    init(networkService: ProductServicesProtocol = ProductServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Submits a new product review after trimming whitespace
    /// - Parameters:
    ///   - productId: The product ID being reviewed
    ///   - rating: Star rating value (e.g. 4.0)
    ///   - reviewText: The written review content
    func submitReview(productId: String, rating: Double, reviewText: String) {
        // Clean up the review text before submitting
        let trimmedReview = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        let input = Inputs(productId: productId, rating: rating, review: trimmedReview)
        
        // Save for potential retry
        self.lastInputs = input
        
        // Submit to API
        createRatingAPI(productId: productId, rating: rating, review: reviewText)
    }
    
    /// Retries the last review submission attempt
    func retry() {
        // Only retry if we have previous inputs
        guard let input = lastInputs else { return }
        createRatingAPI(productId: input.productId, rating: input.rating, review: input.review)
    }
    
    // MARK: - Private Methods
    
    /// Makes the actual API call to submit the review
    private func createRatingAPI(productId: String, rating: Double, review: String) {
        // Validate before submitting
        guard validateInput(description: review) else {
            return
        }
        
        // Set loading state
        state = .loading
        
        networkService.createRatingAPI(productId: productId, rating: rating, review: review)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            // Handle API failure
            if case .failure(let error) = completion {
                self?.state = .failure(error)
            }
        } receiveValue: { [weak self] (_: AddCommentModal) in
            // Mark as successful on valid response
            self?.state = .success
        }
        .store(in: &cancellables)
    }
    
    /// Validates that the review text isn't empty
    /// - Parameter description: The review text to validate
    /// - Returns: True if valid, false if empty (shows error alert)
    private func validateInput(description: String) -> Bool {
        if description.trimmingCharacters(in: .whitespaces).isEmpty {
            // Show error if review is empty
            state = .validationFailure(.validationError(RegexMessages.invalidEmptyDescription))
            
            return false
        }
        return true
    }
}
