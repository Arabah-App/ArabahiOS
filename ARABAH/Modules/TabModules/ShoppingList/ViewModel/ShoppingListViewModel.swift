//
//  ShoppingListViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for managing Shopping List related API calls and data handling.
/// Handles fetching, deleting, and clearing shopping lists, as well as maintaining local data state.
final class ShoppingListViewModel {

    /// Represents the current state of the ViewModel
    enum State {
        case idle                  // Initial state, no operation in progress
        case loading              // API call in progress
        case listSuccess(GetShoppingListModalBody)  // Shopping list fetch succeeded
        case listDeleteSuccess    // Item deletion succeeded
        case listClearSuccess    // List clearing succeeded
        case listFailure(NetworkError)       // Shopping list fetch failed
        case listDeleteFailure(NetworkError) // Item deletion failed
        case listClearFailure(NetworkError)  // List clearing failed
    }

    // MARK: - Properties
    
    /// Published property that notifies subscribers of state changes
    @Published private(set) var state: State = .idle
    
    /// Storage for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Network service instance for making API calls
    private let networkService: HomeServicesProtocol
    
    /// Temporary storage for ID of item being deleted
    private var deleteID: String?

    // MARK: - Data Storage
    
    /// Local storage for shopping list items
    var shoppingList: [ShoppingList] = []
    
    /// Flattened list of all products across all shopping lists
    var products: [Products] = []
    
    /// Summary information about shops in the shopping list
    var shopSummary: [ShopSummary] = []
    
    /// Array of prices for all products
    var totalPrice: [Double] = []

    // MARK: - Initialization
    
    /// Initializes the ViewModel with a network service
    /// - Parameter networkService: The network service to use for API calls (defaults to HomeServices)
    init(networkService: HomeServicesProtocol = HomeServices()) {
        self.networkService = networkService
    }

    // MARK: - Public Methods
    
    /// Fetches the shopping list from the API
    func shoppingListAPI() {
        state = .loading

        networkService.shoppingListAPI()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.state = .listFailure(error)
            }
        } receiveValue: { [weak self] (response: GetShoppingListModal) in
            guard let self = self, var contentBody = response.body else {
                self?.state = .listFailure(.invalidResponse)
                return
            }
            self.cleanShoppingData(model: &contentBody)
            self.products = self.shoppingList.compactMap({ $0.productID?.product ?? [] }).flatMap { $0 }
            self.totalPrice = self.products.map { $0.price ?? 0.0 }
            self.state = .listSuccess(contentBody)
        }
        .store(in: &cancellables)
    }
    
    /// Retries the shopping list API call after a failure
    func retryShoppingListAPI() {
        self.shoppingListAPI()
    }

    /// Deletes an item from the shopping list via API
    /// - Parameter id: The ID of the item to delete
    func shoppingListDeleteAPI(id: String) {
        state = .loading
        
        self.deleteID = id
        networkService.shoppingListDeleteAPI(id: id)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.state = .listDeleteFailure(error)
            }
        } receiveValue: { [weak self] (response: shoppinglistDeleteModal) in
            self?.state = .listDeleteSuccess
        }
        .store(in: &cancellables)
    }

    /// Retries the delete API call after a failure
    func retryListDeleteAPI() {
        guard let id = self.deleteID else { return }
        self.shoppingListDeleteAPI(id: id)
    }
    
    /// Clears all items from the shopping list via API
    func shoppingListClearAllAPI() {
        state = .loading

        networkService.shoppingListClearAllAPI()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.state = .listClearFailure(error)
            }
        } receiveValue: { [weak self] (response: CommentModal) in
            self?.state = .listClearSuccess
        }
        .store(in: &cancellables)
    }

    /// Retries the clear all API call after a failure
    func retryShoppingListClearAllAPI() {
        self.shoppingListClearAllAPI()
    }
    
    // MARK: - Data Cleaning
    
    /// Cleans shopping data by removing shops with all zero-priced products
    /// - Parameter model: The shopping list model to clean (passed as inout to allow modification)
    func cleanShoppingData(model: inout GetShoppingListModalBody) {
        guard var shopSummary = model.shopSummary, var shoppingList = model.shoppingList else {
            self.shoppingList = []
            self.shopSummary = []
            return
        }

        var shopsToRemove = Set<String>()

        // Identify shops where all products have zero price
        for shop in shopSummary {
            guard let shopName = shop.shopName else { continue }
            let allPricesZero = shoppingList
                .compactMap { $0.productID?.product }
                .flatMap { $0 }
                .filter { $0.shopName?.name == shopName }
                .allSatisfy { ($0.price ?? 0) == 0 }

            if allPricesZero {
                shopsToRemove.insert(shopName)
            }
        }

        // Filter out products from shops to be removed
        shoppingList = shoppingList.compactMap { list -> ShoppingList? in
            guard var productID = list.productID else { return list }

            let filteredProducts = productID.product?.filter { product in
                guard let shopName = product.shopName?.name else { return true }
                return !shopsToRemove.contains(shopName)
            } ?? []

            if filteredProducts.isEmpty { return nil }

            productID.product = filteredProducts
            var updatedList = list
            updatedList.productID = productID
            return updatedList
        }

        // Remove empty shops from summary
        shopSummary = shopSummary.filter { shop in
            guard let shopName = shop.shopName else { return true }
            return !shopsToRemove.contains(shopName)
        }

        // Update local storage
        self.shoppingList = shoppingList
        self.shopSummary = shopSummary
    }

    // MARK: - Local Data Management
    
    /// Deletes a product from the local list and returns its ID
    /// - Parameter index: Index of the product to delete
    /// - Returns: The ID of the deleted product, or nil if index is invalid
    func deleteProduct(at index: Int) -> String? {
        guard index >= 0 && index < shoppingList.count else { return nil }
        let id = shoppingList[index].productID?.id
        shoppingList.remove(at: index)
        return id
    }
}
