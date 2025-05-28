//
//  SearchCategoryVC.swift
//  ARABAH
//
//  Created by cql71 on 17/01/25.
//

import UIKit
import SDWebImage

class SearchCategoryVC: UIViewController,UITextFieldDelegate {
    //MARK: - OUTLETS
    @IBOutlet weak var categoryHight: NSLayoutConstraint!
    @IBOutlet weak var lblProdcut: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var productCollection: UICollectionView!
    @IBOutlet weak var recentSearchTbl: UITableView!
    @IBOutlet weak var viewRecentSearch: UIView!
    @IBOutlet weak var searchCollectionCateogy: UICollectionView!
    @IBOutlet weak var txtFldSearch: UITextField!
    //MARK: - VARIABLES
    var viewModal = HomeViewModal()
    var modal : [CreateModalBody]?
    var category: [Categorys]?
    var product: [Producted]?
    var recentModal : [RecentSearchModalBody]?
    var latitude = String()
    var longitude = String()
    var SearchName = String()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        lblProdcut.setLocalizedTitle(key: "Product")
        lblCategory.setLocalizedTitle(key: "Category")
        self.lblProdcut.isHidden = true
        self.lblCategory.isHidden = true
        searchlistapi()
        txtFldSearch.delegate = self
        txtFldSearch.becomeFirstResponder()
        self.viewRecentSearch.isHidden = false
        self.recentSearchTbl.delegate = self
        self.recentSearchTbl.dataSource = self

        if Store.isArabicLang == true{
            txtFldSearch.textAlignment = .right
        }else{
            txtFldSearch.textAlignment = .left
        }

    }
    //MARK: - FUNCTIONS
    func CreateSearch(name:String){
        self.productCollection.isHidden = false
        self.searchCollectionCateogy.isHidden = false
        self.viewRecentSearch.isHidden = true
        viewModal.searchCreateAPI(name: txtFldSearch.text ?? "") { dataa in
            self.modal = dataa
            self.getSerachlist(categoryName: name)
        }
    }
    func getSerachlist(categoryName:String) {
        self.viewRecentSearch.isHidden = true
        viewModal.searchCategoryAPI(categoryName: self.SearchName, longitude: self.longitude, latitude: self.latitude) { dataa
            in
            self.category = dataa?.category ?? []
            self.product = dataa?.products ?? []
            if self.category?.count == 0 {
                self.searchCollectionCateogy.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
                self.categoryHight.constant = 0
            }else {
                self.searchCollectionCateogy.backgroundView = nil
                self.categoryHight.constant = 186
                self.lblCategory.isHidden = false
            }
            
            if self.product?.count == 0 {
                self.productCollection.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
            } else {
                self.productCollection.backgroundView = nil
                self.lblProdcut.isHidden = false
            }
            
            DispatchQueue.main.async {
                self.searchCollectionCateogy.reloadData()
                self.productCollection.reloadData()
            }
        }
    }
    func searchlistapi(){
        viewModal.recentSearchAPI { [weak self] dataa in
            self?.recentModal = dataa?.reversed()
            self?.recentSearchTbl.reloadData()
        }
    }
    func historyDelte(selectedID:String){
        viewModal.historyDeleteAPI(id: selectedID) { dataa in
            self.searchlistapi()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let resultString = textField.text ?? ""
        if resultString.isEmpty {
            self.SearchName = ""
            self.category = nil
            self.searchCollectionCateogy.isHidden = true
        } else {
            self.SearchName = resultString
            self.getSerachlist(categoryName: resultString)
           // CreateSearch(name: resultString)
            self.searchCollectionCateogy.isHidden = false
        }
        // Dismiss the keyboard
        txtFldSearch.resignFirstResponder()
        return true
    }
    
    //MARK: - ACTIONS
    @IBAction func BtnFilter(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        vc.latitude = self.latitude
        vc.longitude = self.longitude
        vc.callback = { [weak self] (value, status) in
            self?.getSerachlist(categoryName: self?.txtFldSearch.text ?? "")
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(vc, animated: false)
    }
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - EXTENSIONS
extension SearchCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == searchCollectionCateogy{
            return category?.count ?? 0
        }else{
            return product?.count ?? 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == searchCollectionCateogy{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCategoryCVC", for: indexPath) as! SearchCategoryCVC
            let imageIndex = (imageURL) + (self.category?[indexPath.row].image ?? "")
            cell.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgView.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
            cell.lblName.text = self.category?[indexPath.row].categoryName ?? ""
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchProductCVC", for: indexPath) as! SearchProductCVC
            let imageIndex = (imageURL) + (self.product?[indexPath.row].image ?? "")
            cell.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgView.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
            cell.lblName.text = self.product?[indexPath.row].name ?? ""
            let currentLang = L102Language.currentAppleLanguageFull()
            let data = self.product?[indexPath.row].product ?? []
            let newproduct = data.sorted(by: {$0.price ?? 0 < $1.price ?? 0})
            let prices = newproduct.map({$0.price ?? 0}) 
            let lowestPrice = prices.min() ?? 0
            
            let val = (lowestPrice == 0) ? "0" : (lowestPrice.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", lowestPrice) : String(format: "%.2f", lowestPrice))
            
            switch currentLang {
            case "ar":
                cell.lblPrice.text = "⃀" + "\(val)" 
            default:
                cell.lblPrice.text = "⃀" + "\(val)" }

            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: 174)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == searchCollectionCateogy{
            let vc = storyboard?.instantiateViewController(withIdentifier: "SubCategoryVC") as! SubCategoryVC
            vc.categoryID = self.category?[indexPath.row].id ?? ""
            vc.categoryName = self.category?[indexPath.row].categoryName ?? ""
            vc.check = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
            vc.productQty = self.product?[indexPath.row].prodiuctUnit ?? ""
            vc.prodcutid = self.product?[indexPath.row].id ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
//MARK: - EXTENSION TABEL VIEW
extension SearchCategoryVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentModal?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchTVC", for: indexPath) as! RecentSearchTVC
        cell.lblName.text = recentModal?[indexPath.row].name ?? ""
        cell.btnCross.tag = indexPath.row
        cell.btnCross.addTarget(self, action: #selector(DeleteBtn(_ :)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.SearchName = recentModal?[indexPath.row].name ?? ""
        self.txtFldSearch.text = recentModal?[indexPath.row].name ?? ""
        self.getSerachlist(categoryName: recentModal?[indexPath.row].name ?? "")
        self.getSerachlist(categoryName: recentModal?[indexPath.row].name ?? "")
        self.viewRecentSearch.isHidden = true
        self.lblProdcut.isHidden = false
        self.lblCategory.isHidden = false
        self.recentSearchTbl.reloadData()
    }
    @objc func DeleteBtn(_ sender: UIButton){
        self.historyDelte(selectedID: self.recentModal?[sender.tag].id ?? "")
    }
}
