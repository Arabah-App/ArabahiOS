//
//  ShoppingListVC.swift
//  ARABAH
//
//  Created by cqlpc on 07/11/24.
//

import UIKit
import SDWebImage
import MBProgressHUD
import Combine

class ShoppingListVC: UIViewController {
    
    // MARK: - IBOutlets
    
    // Clear all button to remove all items from shopping list
    @IBOutlet weak var clearAll: UIButton!
    // Label shown when there's no data available
    @IBOutlet weak var lblNodata: UILabel!
    // Table view displaying the shopping list
    @IBOutlet weak var shoppingListTbl: UITableView!
    // Main view container
    @IBOutlet var viewMain: UIView!
    
    // MARK: - Variables
    
    // ViewModel handling business logic for shopping list
    var viewModel = ShoppingListViewModel()
    // Set of Combine cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    // Synced offset for synchronized scrolling between collection views
    var syncedOffset: CGPoint = .zero
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial setup for authentication state
        self.authNil(val: true)
        // Configure UI elements
        setUpView()
        // Bind ViewModel to ViewController
        bindViewModel()
        // Set up accessibility identifiers for UI testing
        setUpAccessibilityIdentifier()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fetch shopping list data if authenticated
        if let auth = Store.authToken, !auth.isEmpty {
            viewModel.shoppingListAPI()
        }
    }
    
    // MARK: - ViewModel Binding
    
    /// Binds the ViewModel's state to the ViewController
    private func bindViewModel() {
        viewModel.$getListState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.getListState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$listDeleteState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.listDeleteState(state)
            }
            .store(in: &cancellables)
        
        
        viewModel.$listClearState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.listClearState(state)
            }
            .store(in: &cancellables)
        
    }
    
    /// Handles changes in ViewModel state and updates UI accordingly
    
    private func listClearState(_ state: AppState<CommentModal>) {
        
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(_):
            hideLoadingIndicator()
            // Refresh list after successful clear
            viewModel.shoppingListAPI()
        case .failure(let error):
            hideLoadingIndicator()
            showErrorAlertListClear(error: error)
        case .validationError(_):
            hideLoadingIndicator()
        }
    }
    
    private func listDeleteState(_ state: AppState<shoppinglistDeleteModal>) {
        
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(_):
            hideLoadingIndicator()
            // Refresh list after successful deletion
            viewModel.shoppingListAPI()
        case .failure(let error):
            hideLoadingIndicator()
            showErrorAlertDelete(error: error)
        case .validationError(_):
            hideLoadingIndicator()
        }
    }
    
    private func getListState(_ state: AppState<GetShoppingListModalBody>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(_):
            hideLoadingIndicator()
            updateUI()
        case .failure(let error):
            hideLoadingIndicator()
            lblNodata.isHidden = false
            showErrorAlertList(error: error)
        case .validationError(_):
            hideLoadingIndicator()
        }
    }
    
    // MARK: - UI Update
    
    /// Updates the UI based on current data state
    private func updateUI() {
        if viewModel.shoppingList.isEmpty {
            // Show empty state
            clearAll.isHidden = true
            shoppingListTbl.isHidden = true
            lblNodata.isHidden = false
        } else {
            // Show data
            clearAll.isHidden = false
            shoppingListTbl.isHidden = false
            lblNodata.isHidden = true
        }
        
        // Configure table view
        shoppingListTbl.delegate = self
        shoppingListTbl.dataSource = self
        shoppingListTbl.reloadData()
    }
    
    // MARK: - Error Handling
    
    /// Shows error alert for list fetch failure with retry option
    private func showErrorAlertList(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryShoppingListAPI()
        }
    }
    
    /// Shows error alert for delete failure with retry option
    private func showErrorAlertDelete(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryListDeleteAPI()
        }
    }
    
    /// Shows error alert for clear all failure with retry option
    private func showErrorAlertListClear(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryShoppingListClearAllAPI()
        }
    }
    
    // MARK: - UI Setup
    
    /// Sets up initial view configurations
    private func setUpView() {
        clearAll.setLocalizedTitleButton(key: PlaceHolderTitleRegex.clearAll)
    }
    
    /// Sets accessibility identifiers for UI testing
    private func setUpAccessibilityIdentifier() {
        clearAll.accessibilityIdentifier = "clearAllButton"
        lblNodata.accessibilityIdentifier = "noDataLabel"
        shoppingListTbl.accessibilityIdentifier = "shoppingListTable"
    }
    
    // MARK: - Button Actions
    
    /// Clear all button action handler
    @IBAction func btnClear(_ sender: UIButton) {
        viewModel.shoppingListClearAllAPI()
    }
    
    // MARK: - Scroll Synchronization
    
    /// Handles scroll view scrolling to sync collection views
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView {
            syncedOffset = scrollView.contentOffset
            syncCollectionViewScroll()
        }
    }
    
    /// Synchronizes collection view scrolling across all visible cells
    func syncCollectionViewScroll() {
        guard let visibleCell = shoppingListTbl.visibleCells as? [ShoppingListTVC] else { return }
        for cell in visibleCell {
            if cell.cellColl.contentOffset != syncedOffset {
                cell.cellColl.setContentOffset(syncedOffset, animated: false)
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ShoppingListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Additional rows for header and footer
        return viewModel.shoppingList.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = shoppingListTbl.dequeueReusableCell(withIdentifier: "ShoppingListTVC", for: indexPath) as? ShoppingListTVC else {
            return UITableViewCell()
        }
        
        // Set accessibility identifier for testing
        cell.accessibilityIdentifier = "shoppingListCell_\(indexPath.row)"
        
        // Configure cell data
        cell.shopImages = viewModel.products.compactMap { $0.shopName }.removingDuplicates()
        cell.cellColl.tag = indexPath.row
        cell.leftView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        cell.leftView.layer.cornerRadius = 10
        cell.totalPrice = viewModel.totalPrice
        cell.productt = viewModel.products
        cell.shopSummry = viewModel.shopSummary
        cell.cellColl.setContentOffset(ShoppingListTVC.syncedOffset, animated: false)
        
        // Configure different cell types based on index path
        if indexPath.row == 0 {
            // Header cell configuration
            cell.cellBgView.backgroundColor = #colorLiteral(red: 0.9647, green: 0.9686, blue: 0.9765, alpha: 1)
            cell.cellBgView.layer.shadowOpacity = 0
            cell.imgBgView.isHidden = true
            cell.quantityLbl.isHidden = true
            cell.itemLbl.isHidden = true
            cell.leftView.backgroundColor = .clear
        } else if viewModel.shoppingList.count < indexPath.row {
            // Footer cell configuration (total basket)
            cell.cellBgView.backgroundColor = #colorLiteral(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1)
            cell.cellBgView.layer.shadowOpacity = 0
            cell.imgBgView.isHidden = true
            cell.quantityLbl.isHidden = true
            cell.itemLbl.text = PlaceHolderTitleRegex.totalBasket
            cell.itemLbl.isHidden = false
            cell.leftView.backgroundColor = #colorLiteral(red: 0.1019, green: 0.2078, blue: 0.3686, alpha: 1)
            cell.itemLbl.textColor = .white
        } else {
            // Regular product cell configuration
            let modalItem = viewModel.shoppingList[indexPath.row - 1]
            cell.productName = modalItem.productID?.name ?? ""
            cell.product = modalItem.productID?.product ?? []
            cell.cellBgView.backgroundColor = .white
            cell.cellBgView.layer.shadowOpacity = 1
            cell.imgBgView.isHidden = false
            cell.quantityLbl.isHidden = false
            cell.itemLbl.text = modalItem.productID?.name
            cell.itemLbl.isHidden = false
            
            // Load product image if available
            if let imageName = modalItem.productID?.image {
                let image = imageURL + imageName
                cell.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder"))
            } else {
                cell.imgView.image = nil
            }
            
            cell.itemLbl.textColor = #colorLiteral(red: 0.1019, green: 0.2078, blue: 0.3686, alpha: 1)
            cell.leftView.backgroundColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let count = viewModel.shoppingList.count + 1
        
        // Disable swipe actions for header and footer rows
        if indexPath.row == 0 || indexPath.row == count {
            return UISwipeActionsConfiguration()
        }
        
        // Configure delete action for product rows
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] _, _, _ in
            guard let self = self,
                  let vc = self.storyboard?.instantiateViewController(identifier: "popUpVC") as? popUpVC else { return }
            
            vc.modalPresentationStyle = .overFullScreen
            vc.check = .removeProduct
            vc.closure = { [weak self] in
                guard let self = self else { return }
                let deleteIndex = indexPath.row - 1
                if let id = self.viewModel.deleteProduct(at: deleteIndex) {
                    self.viewModel.shoppingListDeleteAPI(id: id)
                    self.shoppingListTbl.deleteRows(at: [indexPath], with: .automatic)
                }
            }
            self.present(vc, animated: true)
        }
        deleteAction.image = UIImage(named: "deleteBtn")
        deleteAction.backgroundColor = #colorLiteral(red: 0.9451, green: 0.9451, blue: 0.9451, alpha: 1)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
