//
//  ShoppingListVC.swift
//  ARABAH
//
//  Created by cqlpc on 07/11/24.
//

import UIKit
import SDWebImage
class ShoppingListVC: UIViewController {

    //MARK: OUTLETS
    @IBOutlet weak var clearAll: UIButton!
    @IBOutlet weak var lblNodata: UILabel!
    @IBOutlet weak var shoppingListTbl: UITableView!
    @IBOutlet var viewMain: UIView!

    //MARK: VARIABLES
    var listItems = ["Tomato", "Broccoli", "Strawberry", "Orange"]
    var viewModal = HomeViewModal()
    var modal : GetShoppingListModalBody?
    var shoppingList: [ShoppingList]?
    var product: [Products]?
    var shopSummry : [ShopSummary]?
    var totalPrice = [Double]()
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authNil(val: true)
        clearAll.setLocalizedTitleButton(key: "Clear all")
    }
    var updatedList: [ShoppingList] = []
    func cleanShoppingData(model: inout GetShoppingListModalBody) {
        guard var shopSummary = model.shopSummary, var shoppingList = model.shoppingList else {
            self.shoppingList = []
            self.shopSummry = []
            return
        }

        var shopsToRemove = Set<String>()

        // Identify shops where all products have price 0
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

        // Remove products from ShoppingList if their shop is in shopsToRemove
        shoppingList = shoppingList.compactMap { list -> ShoppingList? in
            guard var productID = list.productID else { return list }

            let filteredProducts = productID.product?.filter { product in
                guard let shopName = product.shopName?.name else { return true }
                return !shopsToRemove.contains(shopName)
            } ?? []

            if filteredProducts.isEmpty { return nil }  // Remove if no valid products left

            productID.product = filteredProducts
            var updatedList = list
            updatedList.productID = productID  // ✅ Correctly assigning updated product list
            return updatedList
        }

        // Remove the identified shops from shopSummary
        shopSummary = shopSummary.filter { shop in
            guard let shopName = shop.shopName else { return true }
            return !shopsToRemove.contains(shopName)
        }

        // ✅ Update model correctly
        self.shoppingList = shoppingList
        self.shopSummry = shopSummary
    }



    func getListing() {
        viewModal.shoppingListAPI { [weak self] data in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.modal = data
                let obj =  self.cleanShoppingData(model: &self.modal!)

                if self.shoppingList?.count ?? 0 == 0{
                    self.clearAll.isHidden = true
                    self.shoppingListTbl.isHidden = true
                    self.lblNodata.isHidden = false
                }else{
                    self.shoppingListTbl.isHidden = false
                    self.clearAll.isHidden = false
                    self.lblNodata.isHidden = true
                }
                self.product?.removeAll()
                self.product = self.shoppingList?.compactMap({$0.productID?.product ?? []}).flatMap { $0 }
                for i in 0..<(self.product?.count ?? 0) {
                    //print("product?[i]",self.product?[i].price ?? 0)
                    self.totalPrice.append(self.product?[i].price ?? 0.0)
                }

                self.shoppingListTbl.delegate = self
                self.shoppingListTbl.dataSource = self
                self.shoppingListTbl.reloadData()
            }
        }
    }
    func listingDeleteAPI(id:String){
        viewModal.shoopingListDelteAPI(id: id) { dataa in
            self.getListing()
        }
    }
    func clearListing(){
        viewModal.shoppingListClearAllAPI { dataa in
            self.getListing()
        }
    }
    @IBAction func btnClear(_ sender: UIButton) {
        self.clearListing()
    }

    override func viewWillAppear(_ animated: Bool) {
        getListing()
    }
    var syncedOffset: CGPoint = .zero

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView {
            syncedOffset = scrollView.contentOffset
            syncCollectionViewScroll()
        }
    }

    // Function to sync all collection views
    func syncCollectionViewScroll() {
        for cell in shoppingListTbl.visibleCells as! [ShoppingListTVC] {
            if cell.cellColl.contentOffset != syncedOffset {
                cell.cellColl.setContentOffset(syncedOffset, animated: false)
            }
        }
    }
}

//MARK: EXTENSION TABLE VIEW
extension ShoppingListVC:   UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (shoppingList?.count ?? 0) + 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = shoppingListTbl.dequeueReusableCell(withIdentifier: "ShoppingListTVC", for: indexPath) as! ShoppingListTVC
        cell.shopImages = product?.compactMap { $0.shopName } ?? []
        cell.shopImages = cell.shopImages.removingDuplicates()
        cell.cellColl.tag = indexPath.row
        cell.leftView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        cell.leftView.layer.cornerRadius = 10
        cell.totalPrice = self.totalPrice
        cell.productt = self.product
        cell.shopSummry = self.shopSummry
        cell.cellColl.setContentOffset(ShoppingListTVC.syncedOffset, animated: false)

        if indexPath.row == 0 {
            // Sort by row
            cell.cellBgView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.968627451, blue: 0.9764705882, alpha: 1)
            cell.cellBgView.layer.shadowOffset = .zero
            cell.cellBgView.layer.shadowOpacity = 0
            cell.cellBgView.layer.shadowRadius = 0
            cell.imgBgView.isHidden = true
            cell.quantityLbl.isHidden = true
            cell.itemLbl.text = "Sort by".localized() + "\n" + "Emlist".localized()
            cell.itemLbl.isHidden = true
            cell.itemLbl.textColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            cell.leftView.backgroundColor = .clear
        } else if (self.shoppingList?.count ?? 0) < indexPath.row {
            // Total Basket Price row
            cell.cellBgView.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
            cell.cellBgView.layer.shadowOffset = .zero
            cell.cellBgView.layer.shadowOpacity = 0
            cell.cellBgView.layer.shadowRadius = 0
            cell.imgBgView.isHidden = true
            cell.quantityLbl.isHidden = true
            cell.itemLbl.text = "Total Basket".localized()
            cell.itemLbl.isHidden = false
            cell.leftView.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            cell.itemLbl.textColor = .white
        } else {
            // Regular rows
            let modalItem = shoppingList?[indexPath.row - 1]
            cell.productName = modalItem?.productID?.name ?? ""
            cell.product = shoppingList?[indexPath.row - 1].productID?.product ?? []
            cell.cellBgView.backgroundColor = .white
            cell.cellBgView.layer.shadowOffset = .zero
            cell.cellBgView.layer.shadowOpacity = 1
            cell.cellBgView.layer.shadowRadius = 6
            cell.cellBgView.layer.shadowColor = #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 0.43)
            cell.imgBgView.isHidden = false
            cell.quantityLbl.isHidden = false
            cell.itemLbl.text = "\(modalItem?.productID?.name ?? "") "
            cell.itemLbl.isHidden = false
            if let imageName = modalItem?.productID?.image {
                let image = (imageURL) + (imageName)
                cell.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder"))
            } else {
                cell.imgView.image = nil
            }
            cell.itemLbl.textColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            cell.leftView.backgroundColor = .white
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let count = ((shoppingList?.count ?? 0) + 1)
        if indexPath.row == 0 || indexPath.row ==  count{
            return UISwipeActionsConfiguration()
        } else {
            let deleteAction = UIContextualAction(style: .destructive, title: "", handler: {a,b,c in
                let vc = self.storyboard?.instantiateViewController(identifier: "popUpVC") as! popUpVC
                vc.modalPresentationStyle = .overFullScreen
                vc.check = "5"
                vc.closure = {
                    let getid = self.shoppingList?[indexPath.row-1].productID?.id ?? ""
                    self.shoppingList?.remove(at: indexPath.row-1)
                    self.listingDeleteAPI(id: getid)
                    self.shoppingListTbl.deleteRows(at: [indexPath], with: .automatic)
                }
                self.present(vc, animated: true)
            })
            deleteAction.image = UIImage(named: "deleteBtn")
            deleteAction.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
    }
}
extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        return arrayOrdered
    }
}

