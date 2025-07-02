//
//  TermsConditionVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit
import Combine
import MBProgressHUD

class TermsConditionVC: UIViewController {
    
    // MARK: - OUTLETS
    
    /// TextView to display the content (Terms, Privacy Policy, About Us)
    @IBOutlet var txtView: UITextView!
    
    /// Label to display the screen's header title
    @IBOutlet var lblHeader: UILabel!
    
    /// Back button to return to the previous screen
    @IBOutlet var backButton: UIButton!
    
    // MARK: - VARIABLES
    
    /// Type of content to display:
    /// - 0: Terms & Conditions
    /// - 1: About Us
    /// - 2: Privacy Policy
    var contentType: Int = 0
    
    /// ViewModel to handle business logic and API for this screen
    var viewModel = TermPrivacyViewModel()
    
    /// Used to manage Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - VIEW LIFECYCLE
    
    /**
     Called after the view has been loaded into memory.
     Sets up UI and triggers content loading based on `contentType`.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup views and content
        bindViewModel()
        setupViews()
        setupAccessibility()
        fetchContent()
    }
    
    // MARK: - SETUP FUNCTIONS
    
    /// Updates UI elements such as header label text
    private func setupViews() {
        lblHeader.text = headerTitle(for: contentType)
    }
    
    /// Sets accessibility identifiers for UI testing
    private func setupAccessibility() {
        lblHeader.accessibilityIdentifier = "headerLabel"
        backButton.accessibilityIdentifier = "backButton"
        txtView.accessibilityIdentifier = "contentTextView"
    }
    
    /**
     Returns the appropriate header title based on content type.
     
     - Parameter type: Integer value (0, 1, 2)
     - Returns: Localized string for the screen title
     */
    private func headerTitle(for type: Int) -> String {
        switch type {
        case 1:
            return PlaceHolderTitleRegex.aboutUs
        case 2:
            return PlaceHolderTitleRegex.privacyPolicy
        default:
            return PlaceHolderTitleRegex.termsConditions
        }
    }
    
    // MARK: - VIEWMODEL BINDING
    
    /// Binds ViewModel state to UI reactions
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    /// Triggers content fetch API via ViewModel
    private func fetchContent() {
        viewModel.fetchContent(with: contentType)
    }
    
    /// Handles different states returned by the ViewModel
    private func handleStateChange(_ state: TermPrivacyViewModel.State) {
        switch state {
        case .idle:
            break // Do nothing
        case .loading:
            showLoadingIndicator()
        case .success(let contentBody):
            hideLoadingIndicator()
            // Display fetched HTML content as plain text
            txtView.text = contentBody.description?.htmlToString
        case .failure(let error):
            hideLoadingIndicator()
            showErrorAlert(error: error)
        }
    }
    
    // MARK: - LOADING INDICATORS
    
    /// Displays a blocking loading indicator over the view
    private func showLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = false
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    
    /// Hides the loading indicator and re-enables UI interaction
    private func hideLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    /// Displays an error alert with a retry option
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryFetchContent()
        }
    }
    
    // MARK: - ACTIONS
    
    /**
     Handles back button tap.
     Pops the current view controller to return to the previous screen.
     */
    @IBAction func BtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
