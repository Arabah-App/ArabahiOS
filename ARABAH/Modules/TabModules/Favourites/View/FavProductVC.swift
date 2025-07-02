//
//  FavProductVC.swift
//  ARABAH
//
//  ViewController for displaying and managing favorite products
//

import UIKit
import Combine
import MBProgressHUD

class FavProductVC: UIViewController {
    
    // MARK: - Outlets
    
    // Collection view to display favorite products
    @IBOutlet weak var favProdCollection: UICollectionView!
    
    // MARK: - Properties
    
    // ViewModel handling favorite products logic
    var viewModel = FavViewModel()
    
    // Storage for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // ID of the selected provider (if applicable)
    var selectedProviderID = String()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up view model binding
        bindViewModel()
        
        // Configure collection view
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh favorite products list when view appears
        viewModel.getProductfavList()
    }
    
    // MARK: - Setup Methods
    
    /// Configures the collection view delegate and data source
    private func configureCollectionView() {
        favProdCollection.delegate = self
        favProdCollection.dataSource = self
        
        // Set accessibility identifier for UI testing
        favProdCollection.accessibilityIdentifier = "favProdCollection"
        favProdCollection.backgroundView?.accessibilityIdentifier = "noDataLabel"
    }
    
    /// Sets up bindings to ViewModel properties
    private func bindViewModel() {
        // Handle state changes from ViewModel
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
        
        // Reload collection when liked products change
        viewModel.$likedBody
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.favProdCollection.reloadData()
            }
            .store(in: &cancellables)
        
        // Show/hide no data message
        viewModel.$showNoDataMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                if isEmpty {
                    self?.favProdCollection.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
                } else {
                    self?.favProdCollection.backgroundView = nil
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Handling
    
    /// Handles different states from ViewModel
    private func handleStateChange(_ state: FavViewModel.State) {
        switch state {
        case .idle:
            // No action needed for idle state
            break
            
        case .loading:
            // Show loading indicator
            showLoadingIndicator()
            
        case .likeDisLikeSuccess:
            // Handle successful like/dislike action
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: RegexMessages.productDislike, isSuccess: .success)
            
        case .likedListSuccess:
            // Handle successful favorite list fetch
            hideLoadingIndicator()
            
        case .likeDisLikeFailure(let error):
            // Handle like/dislike failure
            hideLoadingIndicator()
            showDislikeErrorAlert(error)
            
        case .likedListFailure(let error):
            // Handle favorite list fetch failure
            hideLoadingIndicator()
            showFavListErrorAlert(error)
        }
    }
    
    // MARK: - Alert Methods
    
    /// Shows error alert for like/dislike failure
    private func showDislikeErrorAlert(_ error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: appName, message: error.localizedDescription) { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
    
    /// Shows error alert for favorite list fetch failure with retry option
    private func showFavListErrorAlert(_ error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.getProductfavList()
        }
    }
    
    // MARK: - Loading Indicators
    
    /// Shows loading spinner and disables user interaction
    private func showLoadingIndicator() {
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            MBProgressHUD.showAdded(to: view, animated: true)
        }
    }
    
    /// Hides loading spinner and enables user interaction
    private func hideLoadingIndicator() {
        view.isUserInteractionEnabled = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
    
    // MARK: - Actions
    
    /// Handles back button tap
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Collection View Delegate & Data Source

extension FavProductVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.likedBody?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavProductCVC", for: indexPath) as? FavProductCVC else {
            return UICollectionViewCell()
        }
        
        // Configure cell with product data
        if let model = viewModel.likedBody?[indexPath.row] {
            cell.setupObj = model
            // Set favorite button state based on product status
            cell.btnFav.isSelected = model.status == 0
            cell.btnFav.tag = indexPath.row
            // Add target for favorite button tap
            cell.btnFav.addTarget(self, action: #selector(BtnLike(_:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    // MARK: - Delegate
    
    /// Handles favorite button tap in collection view cells
    @objc func BtnLike(_ sender: UIButton) {
        let productID = viewModel.likedBody?[sender.tag].productID?.id ?? ""
        // Call like/dislike API for the tapped product
        viewModel.likeDislikeAPI(productID: productID)
    }
    
    /// Returns size for collection view items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Two items per row with fixed height
        return CGSize(width: favProdCollection.frame.width / 2, height: 163)
    }
    
    /// Handles product selection in collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Navigate to product detail screen
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as? SubCatDetailVC else { return }
        vc.prodcutid = viewModel.likedBody?[indexPath.row].productID?.id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
