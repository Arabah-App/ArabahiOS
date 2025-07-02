//
//  FavViewModel.swift
//  ARABAH
//
//  ViewModel handling favorite products logic and API interactions
//

import UIKit
import Combine

final class FavViewModel {
    
    // MARK: - Output States
    
    /// Represents the different states the ViewModel can be in
    enum State: Equatable {
        case idle  // Initial state, no operations ongoing
        case loading  // API call in progress
        case likeDisLikeSuccess  // Successfully liked/disliked a product
        case likedListSuccess  // Successfully fetched favorite products
        case likeDisLikeFailure(NetworkError)  // Failed to like/dislike
        case likedListFailure(NetworkError)  // Failed to fetch favorites
    }
    
    // MARK: - Published Properties
    
    /// Current state of the ViewModel (observable by views)
    @Published private(set) var state: State = .idle
    
    /// Array of favorite products (observable by views)
    @Published private(set) var likedBody: [LikeProductModalBody]? = []
    
    /// Flag to show/hide "no data" message (observable by views)
    @Published var showNoDataMessage: Bool = false
    
    // MARK: - Private Properties
    
    /// Storage for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Service handling product-related network calls
    private let networkService: ProductServicesProtocol
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with optional network service
    /// - Parameter networkService: Service conforming to ProductServicesProtocol (defaults to ProductServices)
    init(networkService: ProductServicesProtocol = ProductServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Handles like/dislike action for a product
    /// - Parameter productID: The ID of the product to like/dislike
    func likeDislikeAPI(productID: String) {
        // Set loading state before API call
        state = .loading
        
        networkService.likeDislikeAPI(productID: productID)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            // Handle API failure
            if case .failure(let error) = completion {
                self?.state = .likeDisLikeFailure(error)
            }
        } receiveValue: { [weak self] (response: LikeModal) in
            // Handle successful like/dislike
            self?.state = .likeDisLikeSuccess
            
            // Refresh the favorites list to reflect changes
            self?.getProductfavList()
        }
        .store(in: &cancellables)
    }

    /// Fetches the current list of favorite products
    func getProductfavList() {
        state = .loading
        
        networkService.getProductfavList()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            // Handle API failure
            if case .failure(let error) = completion {
                self?.state = .likedListFailure(error)
                
                // Clear existing data and show no data message
                self?.likedBody = []
                self?.showNoDataMessage = true
            }
        } receiveValue: { [weak self] (response: LikeProductModal) in
            // Validate response contains body
            guard let contentBody = response.body else {
                self?.state = .likedListFailure(.invalidResponse)
                self?.likedBody = []
                self?.showNoDataMessage = true
                return
            }
            
            // Update data and UI state
            self?.likedBody = contentBody
            self?.showNoDataMessage = contentBody.isEmpty
            self?.state = .likedListSuccess
        }
        .store(in: &cancellables)
    }
}
