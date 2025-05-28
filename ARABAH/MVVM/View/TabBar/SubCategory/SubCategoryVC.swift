//
//  SubCategoryVC.swift
//  ARABAH
//
//  Created by cqlios on 23/10/24.
//

import UIKit
import SDWebImage
import SkeletonView

class SubCategoryVC: UIViewController {
    //MARK: - OUTLETS
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var subCategoryColl: UICollectionView!
    @IBOutlet weak var headerLbll: UILabel!
    
    //MARK: - VARIABELS
    var latProduct : [LatestProduct]?
    var latestModal : [LatestProModalBody]?
    var product: [Product]?
    var viewModal = HomeViewModal()
    var modal : [SubCatProductModalBody]?
    var similarModal : [SimilarProductModalBody]?
    var idCallback: ((String) -> ())?
    var categoryID:String = ""
    var check = Int()
    var categoryName = String()
    var isLoading = true // Track loading state
    var productID = String()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        if check == 1 {
            headerLbll.text = categoryName
            subCatAPI()
        } else if check == 2 {

            getSimilarProductAPI()
            headerLbll.text = "Similar Products".localized()
        } else {

            getlatProductAPI()
            headerLbll.text = "Latest Products".localized()
        }
        // Add Refresh Control to Collection View
        if #available(iOS 10.0, *) {
            subCategoryColl.refreshControl = refreshControl
        } else {
            subCategoryColl.addSubview(refreshControl)
        }

        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    @objc private func refreshData() {
        if check == 1 {
            headerLbll.text = categoryName
            if Store.authToken == nil || Store.authToken == ""{

            } else {
                subCatAPI()
            }
        } else if check == 2 {
            getSimilarProductAPI()
            headerLbll.text = "Similar Products".localized()
        } else {
            getlatProductAPI()
            headerLbll.text = "Latest Products".localized()
        }
    }

    //MARK: - FUNCTION
    func subCatAPI() {
        viewModal.subCatProduct(cateogyID: self.categoryID) { [weak self] dataa in
            self?.modal = dataa
            if self?.modal?.count == 0{
                self?.subCategoryColl.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
            }else{
                self?.subCategoryColl.backgroundView = nil
            }
            self?.isLoading = false
            self?.refreshControl.endRefreshing()
            self?.subCategoryColl.reloadData()
        }
    }
    
    func getlatProductAPI(){
        viewModal.getLatestProductAPI { [weak self] dataa in
            self?.latestModal = dataa
            if self?.modal?.count == 0{
                self?.subCategoryColl.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
            }else{
                self?.subCategoryColl.backgroundView = nil
            }
            self?.isLoading = false
            self?.refreshControl.endRefreshing()
            self?.subCategoryColl.reloadData()
        }
    }
    
    func getSimilarProductAPI(){
        viewModal.getSimilarProductAPI(id: self.productID) { [weak self] dataa in
            self?.similarModal = dataa
            if self?.similarModal?.count == 0{
                self?.subCategoryColl.setNoDataMessage("No Data found".localized(), txtColor: UIColor.set)
            }else{
                self?.subCategoryColl.backgroundView = nil
            }
            self?.isLoading = false
            self?.refreshControl.endRefreshing()
            self?.subCategoryColl.reloadData()
        }
    }
    //MARK: - ACTIONS
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
//MARK: - EXTENSIONS
extension SubCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if check == 1 {
            if isLoading == true {
                return 10
            } else {
                return modal?.count ?? 0
            }
        }else if check == 2{
            if isLoading == true {
                return 10
            } else {
                return similarModal?.count ?? 0
            }
        }else{
            if isLoading == true {
                return 10
            } else {
                return latestModal?.count ?? 0
            }
        }

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if check == 1 {
            let cell = subCategoryColl.dequeueReusableCell(withReuseIdentifier: "SubCategoryCVC", for: indexPath) as! SubCategoryCVC
          
            cell.imgView.isSkeletonable = true
            cell.imgView.showAnimatedGradientSkeleton()
            cell.lblName.isSkeletonable = true
            cell.lblName.showAnimatedGradientSkeleton()
            cell.lblProductUnit.isSkeletonable = true
            cell.lblProductUnit.showAnimatedGradientSkeleton()
            cell.lblPrice.isSkeletonable = true
            cell.lblPrice.showAnimatedGradientSkeleton()
            cell.btnAdd.isSkeletonable = true
            cell.btnAdd.layer.cornerRadius = cell.btnAdd.frame.size.width / 2
            cell.btnAdd.clipsToBounds = true
            cell.btnAdd.showAnimatedGradientSkeleton()
            
            if isLoading != true {
                cell.lblName.hideSkeleton()
                cell.lblName.text = modal?[indexPath.row].name ?? ""
                let CatimageIndex = (imageURL) + (modal?[indexPath.row].image ?? "")
                cell.imgView.sd_setImage(with: URL(string: CatimageIndex), placeholderImage: UIImage(named: "Placeholder")) { _, _, _, _ in
                    // Hide skeleton after image is loaded
                    cell.imgView.hideSkeleton()
                }
                cell.lblPrice.hideSkeleton()
                let minprice = modal?[indexPath.row].product ?? []
                //cell.lblPrice.text = "⃀ ".localized() +
                cell.lblProductUnit.hideSkeleton()
                
                let lowestPrice = (minprice.compactMap({$0.price}).min() ?? 0.0)
                
                if lowestPrice == 0 {
                    cell.lblProductUnit.text = "⃀ 0"
                } else {
                    let formatted = (lowestPrice.truncatingRemainder(dividingBy: 1) == 0) ?
                        String(format: "%.0f", lowestPrice) :
                        String(format: "%.2f", lowestPrice).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
                    cell.lblProductUnit.text = "⃀ \(formatted)"
                }
                
//                let val = (lowestPrice == 0) ? "-" : ((lowestPrice).truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", lowestPrice) : String(format: "%.2f", lowestPrice))
//                
//                cell.lblProductUnit.text =  val
                cell.btnAdd.hideSkeleton()
                cell.btnAdd.tag = indexPath.row
                cell.btnAdd.addTarget(self, action: #selector(addbtn(_:)), for: .touchUpInside)
            }
            return cell
        }else if check == 2{
            let cell = subCategoryColl.dequeueReusableCell(withReuseIdentifier: "SubCategoryCVC", for: indexPath) as! SubCategoryCVC
            cell.imgView.isSkeletonable = true
            cell.imgView.showAnimatedGradientSkeleton()
            cell.lblName.isSkeletonable = true
            cell.lblName.showAnimatedGradientSkeleton()
            cell.lblProductUnit.isSkeletonable = true
            cell.lblProductUnit.showAnimatedGradientSkeleton()
            cell.lblPrice.isSkeletonable = true
            cell.lblPrice.showAnimatedGradientSkeleton()
            cell.btnAdd.isSkeletonable = true
            cell.btnAdd.layer.cornerRadius = cell.btnAdd.frame.size.width / 2
            cell.btnAdd.clipsToBounds = true
            cell.btnAdd.showAnimatedGradientSkeleton()
            if isLoading != true {
                cell.lblName.hideSkeleton()
                cell.lblName.text = similarModal?[indexPath.row].name ?? ""
                let CatimageIndex = (imageURL) + (similarModal?[indexPath.row].image ?? "")
                cell.imgView.sd_setImage(with: URL(string: CatimageIndex), placeholderImage: UIImage(named: "Placeholder")) { _, _, _, _ in
                    // Hide skeleton after image is loaded
                    cell.imgView.hideSkeleton()
                }
                cell.lblPrice.hideSkeleton()
                let minprice = similarModal?[indexPath.row].product ?? []
                
                let lowestPrice = (minprice.compactMap({$0.price}).min() ?? 0)
//                let val = (lowestPrice == 0) ? "-" : ((lowestPrice).truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", lowestPrice) : String(format: "%.2f", lowestPrice))
                
                //cell.lblPrice.text = "⃀ ".localized() +
                cell.lblProductUnit.hideSkeleton()
              //  cell.lblProductUnit.text = val
                
                
                if lowestPrice == 0 {
                    cell.lblProductUnit.text = "⃀ 0"
                } else {
                    let formatted = (lowestPrice.truncatingRemainder(dividingBy: 1) == 0) ?
                        String(format: "%.0f", lowestPrice) :
                        String(format: "%.2f", lowestPrice).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
                    cell.lblProductUnit.text = "⃀ \(formatted)"
                }
                cell.btnAdd.tag = indexPath.row
                cell.btnAdd.hideSkeleton()
                cell.btnAdd.addTarget(self, action: #selector(addbtn(_:)), for: .touchUpInside)
            }
            return cell
        }else{
            let cell = subCategoryColl.dequeueReusableCell(withReuseIdentifier: "SubCategoryCVC", for: indexPath) as! SubCategoryCVC
            cell.imgView.isSkeletonable = true
            cell.imgView.showAnimatedGradientSkeleton()
            cell.lblName.isSkeletonable = true
            cell.lblName.showAnimatedGradientSkeleton()
            cell.lblProductUnit.isSkeletonable = true
            cell.lblProductUnit.showAnimatedGradientSkeleton()
            cell.lblPrice.isSkeletonable = true
            cell.lblPrice.showAnimatedGradientSkeleton()
            cell.btnAdd.isSkeletonable = true
            cell.btnAdd.layer.cornerRadius = cell.btnAdd.frame.size.width / 2
            cell.btnAdd.clipsToBounds = true
            cell.btnAdd.showAnimatedGradientSkeleton()
            if isLoading != true {
                cell.lblName.hideSkeleton()
                cell.lblName.text = latestModal?[indexPath.row].name ?? ""
                let CatimageIndex = (imageURL) + (latestModal?[indexPath.row].image ?? "")
                cell.imgView.sd_setImage(with: URL(string: CatimageIndex), placeholderImage: UIImage(named: "Placeholder")) { _, _, _, _ in
                    // Hide skeleton after image is loaded
                    cell.imgView.hideSkeleton()
                }
                cell.lblPrice.hideSkeleton()
                let minprice = latestModal?[indexPath.row].product ?? []
                let lowestPrice = (minprice.compactMap({$0.price}).min() ?? 0)
//                let val = (lowestPrice == 0) ? "-" : ((lowestPrice).truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", lowestPrice) : String(format: "%.2f", lowestPrice))
                cell.lblProductUnit.hideSkeleton()
               // cell.lblProductUnit.text = val
                
                if lowestPrice == 0 {
                    cell.lblProductUnit.text = "⃀ 0"
                } else {
                    let formatted = (lowestPrice.truncatingRemainder(dividingBy: 1) == 0) ?
                        String(format: "%.0f", lowestPrice) :
                        String(format: "%.2f", lowestPrice).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
                    cell.lblProductUnit.text = "⃀ \(formatted)"
                }
                cell.btnAdd.tag = indexPath.row
                cell.btnAdd.hideSkeleton()
                cell.btnAdd.addTarget(self, action: #selector(addbtn(_:)), for: .touchUpInside)
            }
            return cell
        }
    }
    @objc func addbtn(_ sender:UIButton) {
        if Store.authToken == nil || Store.authToken == "" {
            self.authNil()
        } else {
            if check == 2{
                addShopping(getId: similarModal?[sender.tag].id ?? "")
            } else if check == 3 {
                addShopping(getId: latestModal?[sender.tag].id ?? "")
            } else {
                addShopping(getId: modal?[sender.tag].id ?? "")
            }
        }
    }

    func addShopping(getId:String){
        viewModal.addShoppingAPI(productID: getId) { dataa in
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return(CGSize(width: subCategoryColl.frame.width/2, height: 186))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if check == 1 {
            if isLoading == false{
                let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
                vc.prodcutid = self.modal?[indexPath.row].id ?? ""
                vc.productQty = self.modal?[indexPath.row].ProdiuctUnit ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if check == 2 {
            if isLoading == false{
                let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
                if let selectedID = self.similarModal?[indexPath.row].id {
                    self.idCallback?(selectedID)
                    // Pass the ID back via callback
                    self.navigationController?.popViewController(animated: false)
                } else {
                    print("ID is nil for the selected item")
                }
            }
            
        }else{
            if isLoading == false{
                let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
                vc.prodcutid = self.latestModal?[indexPath.row].id ?? ""
                vc.productQty = self.latestModal?[indexPath.row].prodiuctUnit ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
