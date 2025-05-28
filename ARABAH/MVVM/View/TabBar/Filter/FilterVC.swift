//
//  FilterVC.swift
//  ARABAH
//
//  Created by cqlios on 22/10/24.
//

import UIKit

class FilterVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var clearAllBn: UIButton!
    @IBOutlet weak var lblFilter: UILabel!
    @IBOutlet weak var fitlerTbl: UITableView!
    @IBOutlet var btnApply: UIButton!
    @IBOutlet var viewMain: UIView!
    //MARK: - VARIABLES
    var category : [Categorys]?
    var StoreData : [Stores]?
    var Brand : [Brand]?
    var viewModal = HomeViewModal()
    var latitude = String()
    var longitude = String()
    var callback: ((String,Bool)->())?
    var HeaderSection = ["Categories".localized(), "Store Name".localized(), "Brand Name".localized()]
    var selectedCategoryIDs = [String]()
    var selectedStoreIDs = [String]()
    var selectedBrandIDs = [String]()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchfilterListing()
        self.lblFilter.setLocalizedTitle(key: "Filter")
        self.clearAllBn.setLocalizedTitleButton(key: "Clear")
        self.authNil()
        viewMain.layer.cornerRadius = 26
        viewMain.layer.masksToBounds = true
        viewMain.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        btnApply.layer.cornerRadius = 8
        btnApply.layer.masksToBounds = true
    }
    
    func fetchfilterListing(){
        viewModal.fetchFilterDataAPI(latitude: self.latitude, longitude: self.longitude) { dataa in
                self.category = dataa?.category ?? []
                self.StoreData = dataa?.store ?? []
                self.Brand = dataa?.brand ?? []
                let storedFilters = Store.filterdata ?? []
//                self.selectedCategoryIDs = storedFilters.filter { id in self.category?.contains { $0.id == id } ?? false }
//                self.selectedStoreIDs = storedFilters.filter { id in self.StoreData?.contains { $0.id == id } ?? false }
//                self.selectedBrandIDs = storedFilters.filter { id in self.Brand?.contains { $0.id == id } ?? false }
            
            
            self.selectedCategoryIDs = storedFilters
            self.selectedStoreIDs = Store.filterStore ?? []
            self.selectedBrandIDs = Store.fitlerBrand ?? []
            self.fitlerTbl.reloadData()
            }
    }
    
    //MARK: - ACTIONS
    @IBAction func btnApply(_ sender: UIButton) {
        var selectedData: [String] = []
        if !selectedCategoryIDs.isEmpty {
            selectedData.append("Categories: " + selectedCategoryIDs.joined(separator: ","))
        }
        if !selectedStoreIDs.isEmpty {
            selectedData.append("Store Name: " + selectedStoreIDs.joined(separator: ","))
        }
        if !selectedBrandIDs.isEmpty {
            selectedData.append("Brand Name: " + selectedBrandIDs.joined(separator: ","))
        }
        let finalSelectedString = selectedData.joined(separator: "&") // Format output
        self.dismiss(animated: true) {
            Store.fitlerBrand = self.selectedBrandIDs
            Store.filterStore = self.selectedStoreIDs
            Store.filterdata = self.selectedCategoryIDs
            self.callback?(finalSelectedString, false)
        }
    }
    
    @IBAction func btnClear(_ sender: UIButton) {
        selectedCategoryIDs.removeAll()
        selectedBrandIDs.removeAll()
        selectedStoreIDs.removeAll()
        fitlerTbl.reloadData()
        Store.filterdata = nil
        Store.fitlerBrand = nil
        Store.filterStore = nil
        self.callback?("", true)
    }
    
    @IBAction func btnDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
//MARK: - EXTENSIONS
extension FilterVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return HeaderSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return category?.count ?? 0
        case 1: return StoreData?.count ?? 0
        case 2: return Brand?.count ?? 0     // Brand Name
        default: return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterHeaderTVC") as! FilterHeaderTVC
        cell.lblHeader.text = HeaderSection[section]  // Set header text
        return cell.contentView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTVC", for: indexPath) as! FilterTVC
        
        switch indexPath.section {
        case 0:
            let category = category?[indexPath.row]
            cell.lblName?.text = category?.categoryName ?? "Unknown Category"
            let categoryID = category?.id ?? ""
            cell.btnCheck.setImage(selectedCategoryIDs.contains(categoryID) ? UIImage(named: "Check") : UIImage(named: "UnCheck"), for: .normal)
        case 1:
            let storeName = StoreData?[indexPath.row]
            cell.lblName?.text = storeName?.name ?? ""
            let storeID = storeName?.id ?? ""
            cell.btnCheck.setImage(selectedStoreIDs.contains(storeID) ? UIImage(named: "Check") : UIImage(named: "UnCheck"), for: .normal)
        case 2:
            let brandName = Brand?[indexPath.row]
            cell.lblName?.text = brandName?.brandname ?? ""
            let BrandID = brandName?.id ?? ""
            cell.btnCheck.setImage(selectedBrandIDs.contains(BrandID) ? UIImage(named: "Check") : UIImage(named: "UnCheck"), for: .normal)
        default:
            cell.lblName?.text = "Unknown"
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let categoryID = category?[indexPath.row].id else { return }
            toggleSelection(for: categoryID, in: 0)
        case 1:
            guard let storeID = StoreData?[indexPath.row].id else { return  }  // Assuming store IDs are unique
            toggleSelection(for: storeID, in: 1)
        case 2:
            guard let brandID = Brand?[indexPath.row].id else { return }  // Assuming brand IDs are unique
            toggleSelection(for: brandID, in: 2)
        default:
            break
        }
        tableView.reloadData() // Refresh UI
    }
    
    func toggleSelection(for id: String, in section: Int) {
        switch section {
        case 0:
            if selectedCategoryIDs.contains(id) {
                selectedCategoryIDs.removeAll { $0 == id }
            } else {
                selectedCategoryIDs.append(id)
            }
        case 1:
            if selectedStoreIDs.contains(id) {
                selectedStoreIDs.removeAll { $0 == id }
            } else {
                selectedStoreIDs.append(id)
            }
        case 2:
            if selectedBrandIDs.contains(id) {
                selectedBrandIDs.removeAll { $0 == id }
            } else {
                selectedBrandIDs.append(id)
            }
        default:
            break
        }
        
        // ✅ Fix: Always reload the table to reflect changes
        fitlerTbl.reloadData()
    }
}
