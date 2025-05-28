//
//  HomeTVC.swift
//  VenteUser
//
//  Created by cqlpc on 24/10/24.
//

import UIKit
import SDWebImage
import SkeletonView

class HomeTVC: UITableViewCell {
    //MARK: OUTLETS
    @IBOutlet weak var homeColl: UICollectionView!
    @IBOutlet weak var headerBgView: UIView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet var btnSeeAll: UIButton!
    var isLoading: Bool = true
    //MARK: VARIABLES
    
    
    var banner : [Banner]?
    var category : [Categorys]?
    var latProduct : [LatestProduct]?
    var sectionTitle = String() {
        didSet {
            configureCollectionViewLayout()
        }
    }
    
    var categoryary = ["Fruits", "Vegetables", "Beverages", "Dairy"]
    var categoryImg = ["Rectangle 15", "Rectangle 12", "Rectangle 13", "Rectangle 14"]
    var productsAry = ["Tomato", "Broccoli", "Banana"]
    var viewModal = HomeViewModal()
    override func awakeFromNib() {
        super.awakeFromNib()
        homeColl.dataSource = self
        homeColl.delegate = self
        
    }
    //MARK: FUNCTIONS
    func configureCollectionViewLayout() {
        if let layout = homeColl.collectionViewLayout as? UICollectionViewFlowLayout {
            if sectionTitle == "Categories" {
                layout.scrollDirection = .vertical
                homeColl.isPagingEnabled = false
            } else if sectionTitle == "banner" {
                layout.scrollDirection = .horizontal
                homeColl.isPagingEnabled = true
            } else {
                layout.scrollDirection = .horizontal
                homeColl.isPagingEnabled = false
            }
            homeColl.collectionViewLayout.invalidateLayout()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
//MARK: EXTENSION COLLECTION VIEW
extension HomeTVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if homeColl.tag == 0 {
            if isLoading == false {
                return banner?.count ?? 0
            } else {
                return 1
            }
        } else if homeColl.tag == 1 {
            if isLoading == false {
                return category?.count ?? 0
            } else {
                return 4
            }
        } else {
            if isLoading == false {
                return latProduct?.count ?? 0
            } else {
                return 2
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if homeColl.tag == 0 {
            let cell = homeColl.dequeueReusableCell(withReuseIdentifier: "AdBannerCVC", for: indexPath) as! AdBannerCVC
            cell.imgView.isSkeletonable = true
            cell.imgView.showAnimatedGradientSkeleton()

            if isLoading != true {
                let imageIndex = (imageURL) + (self.banner?[indexPath.row].image ?? "")

                cell.imgView.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder")) { _, _, _, _ in
                    // Hide skeleton after image is loaded
                    cell.imgView.hideSkeleton()
                }
            }
            headerBgView.isHidden = true
            return cell
        } else if homeColl.tag == 1 {
            let cell = homeColl.dequeueReusableCell(withReuseIdentifier: "CategoriesCVC", for: indexPath) as! CategoriesCVC
            cell.imgView.isSkeletonable = true
            cell.imgView.showAnimatedGradientSkeleton()

            cell.lblName.isSkeletonable = true
            cell.lblName.showAnimatedGradientSkeleton()
            if isLoading != true {
                cell.lblName.hideSkeleton()
                cell.lblName.text = category?[indexPath.row].categoryName ?? ""
                let CatimageIndex = (imageURL) + (self.category?[indexPath.row].image ?? "")                
                cell.imgView.sd_setImage(with: URL(string: CatimageIndex), placeholderImage: UIImage(named: "Placeholder")) { _, _, _, _ in
                    // Hide skeleton after image is loaded
                    cell.imgView.hideSkeleton()
                }
            }

            headerBgView.isHidden = false
            return cell
        } else {
            let cell = homeColl.dequeueReusableCell(withReuseIdentifier: "ProductsCVC", for: indexPath) as! ProductsCVC
            cell.lblName.isSkeletonable = true
            cell.lblName.showAnimatedGradientSkeleton()

            cell.lblRs.isSkeletonable = true
            cell.lblRs.showAnimatedGradientSkeleton()

            cell.imgView.isSkeletonable = true
            cell.imgView.showAnimatedGradientSkeleton()

            cell.lblKg.isSkeletonable = true
            cell.lblKg.showAnimatedGradientSkeleton()



            if isLoading != true {
                cell.lblName.hideSkeleton()
                cell.lblRs.hideSkeleton()
                cell.lblKg.hideSkeleton()

                cell.lblName.text = latProduct?[indexPath.row].name ?? ""
                let minprice = latProduct?[indexPath.row].product ?? []
                let  minValue = (minprice.compactMap({$0.price}).min() ?? 0.0)
                let val = (minValue == 0) ? "0" : (minValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", minValue) : String(format: "%.2f", minValue))
                
                let currentLang = L102Language.currentAppleLanguageFull()
                switch currentLang {
                case "ar":
                    cell.lblRs.text = " ⃀ " + val + " " + "From".localized()
                default:
                    cell.lblRs.text = "From".localized() + " ⃀ " + val }
                
                
                let latProdimgIndex = (imageURL) + (self.latProduct?[indexPath.row].image ?? "")
                cell.imgView.sd_setImage(with: URL(string: latProdimgIndex), placeholderImage:UIImage(named: "Placeholder")) { _, _, _, _ in
                    cell.imgView.hideSkeleton()
                }
                cell.lblKg.text = ""
               // cell.lblKg.text = latProduct?[indexPath.row].productUnitId?.prodiuctUnit ?? ""
                headerBgView.isHidden = false
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if homeColl.tag == 0 {

            return CGSize(width: homeColl.layer.bounds.width, height: self.frame.size.width / 2)
        } else if homeColl.tag == 1 {
            return CGSize(width: homeColl.layer.bounds.width / 2, height: 152)
        } else {
            return CGSize(width: homeColl.layer.bounds.width / 2.3, height: 145)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isLoading != true {
            if homeColl.tag == 0 {
            }else if homeColl.tag == 1{
                let vc = super.viewContainingController()?.storyboard?.instantiateViewController(withIdentifier: "SubCategoryVC") as! SubCategoryVC
                vc.categoryName = category?[indexPath.row].categoryName ?? ""
                vc.categoryID = category?[indexPath.row].id ?? ""
                vc.check = 1
                super.viewContainingController()?.navigationController?.pushViewController(vc, animated: true)
            } else if homeColl.tag == 2 {
                let vc = super.viewContainingController()?.storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
                vc.prodcutid = latProduct?[indexPath.row].id ?? ""
                super.viewContainingController()?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
//MARK: - UITABLEVIEW CELL
extension UITableViewCell {
    func viewContainingController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
