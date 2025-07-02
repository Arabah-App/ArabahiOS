//
//  ProfileViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for handling profile-related network interactions.
final class ProfileViewModel {
    
    // MARK: - Input & Output
    
    /// Struct used to pass action data into the ViewModel.
    struct Input {
        let notificationStatus: Int?
        let actionType: ActionType
    }
    
    /// Enum representing the types of actions this ViewModel can perform.
    enum ActionType {
        case getProfile
        case updateNotification(Int)
        case deleteAccount
        case logout
    }
    
    /// Enum representing the current state of the view or process.
    enum State {
        case idle
        case loading
        case profileLoaded(LoginModalBody)
        case notificationUpdated
        case accountDeleted
        case loggedOut
        case loadProfilefailure(NetworkError)
        case notiUpdatefailure(NetworkError)
        case accDeletefailure(NetworkError)
        case logOutfailure(NetworkError)
    }
    
    // MARK: - Properties
    
    /// Current state of the ViewModel; UI listens to this.
    @Published private(set) var state: State = .idle
    
    /// Stores Combine cancellables.
    private var cancellables = Set<AnyCancellable>()
    
    /// API service to perform auth/profile-related calls.
    private let authServices: AuthServicesProtocol
    
    /// Temporary storage for notification status update.
    private var updateNotiParam: Int?
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with the given auth service.
    init(authServices: AuthServicesProtocol = AuthServices()) {
        self.authServices = authServices
    }
    
    // MARK: - Public Methods
    
    /// Handles all supported actions (e.g. fetch profile, logout).
    /// - Parameter input: Defines what action to perform and with what data.
    func performAction(input: Input) {
        state = .loading
        
        switch input.actionType {
        case .getProfile:
            getProfile()
        case .updateNotification(let status):
            updateNotificationStatus(status: status)
        case .deleteAccount:
            deleteAccount()
        case .logout:
            logout()
        }
    }
    
    // MARK: - Private Methods
    
    /// Calls the getProfile API and updates state accordingly.
    private func getProfile() {
        authServices.getProfile()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .loadProfilefailure(error)
                }
            } receiveValue: { [weak self] (response: LoginModal) in
                Store.userDetails = response
                if let body = response.body {
                    self?.state = .profileLoaded(body)
                }
            }
            .store(in: &cancellables)
    }
    
    /// Checks if the current profile is incomplete.
    /// - Returns: True if name, email, or image is missing.
    func shouldShowCompleteProfile() -> Bool {
        guard let userData = Store.userDetails?.body else { return true }
        return userData.image?.isEmpty ?? true ||
               userData.name?.isEmpty ?? true ||
               userData.email?.isEmpty ?? true
    }
    
    /// Updates the notification status through API.
    /// - Parameter status: Integer representing notification on/off.
    private func updateNotificationStatus(status: Int) {
        updateNotiParam = status
        
        authServices.updateNotificationStatus(status: status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .notiUpdatefailure(error)
                }
            } receiveValue: { [weak self] (_: LoginModal) in
                // Update local cache and UI
                Store.userDetails?.body?.isNotification = status
                self?.state = .notificationUpdated
            }
            .store(in: &cancellables)
    }
    
    /// Retries the last failed notification status update.
    func retryUpdateNotiStatus() {
        if let input = updateNotiParam {
            state = .idle
            self.updateNotificationStatus(status: input)
        }
    }
    
    /// Deletes the user's account from the backend.
    private func deleteAccount() {
        authServices.deleteAccount()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .accDeletefailure(error)
                }
            } receiveValue: { [weak self] (_: LoginModal) in
                self?.clearUserSession()
                self?.state = .accountDeleted
            }
            .store(in: &cancellables)
    }
    
    /// Retries the last failed account deletion.
    func retryDeleteAccount() {
        state = .idle
        self.deleteAccount()
    }
    
    /// Logs the user out by calling the logout API.
    private func logout() {
        authServices.logout()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .logOutfailure(error)
                }
            } receiveValue: { [weak self] (_: LoginModal) in
                self?.clearUserSession()
                self?.state = .loggedOut
            }
            .store(in: &cancellables)
    }
    
    /// Retries the logout API call.
    func retryLogout() {
        state = .idle
        self.logout()
    }
    
    /// Clears all user-related data from the session (used after logout or account delete).
    private func clearUserSession() {
        Store.remove = .userDetails
        Store.remove = .authKey
        Store.autoLogin = false
        Store.filterdata = nil
        Store.fitlerBrand = nil
        Store.filterStore = nil
        Store.authToken = nil
        Store.isfromsecure = ""
    }
}
