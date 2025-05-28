//
//  ShoppingListTVC.swift
//  ARABAH
//
//  Created by cqlpc on 07/11/24.
//

import UIKit
import SDWebImage

class ShoppingListTVC: UITableViewCell, UIScrollViewDelegate {
    
    //MARK: OUTLETS
    @IBOutlet weak var cellColl: UICollectionView!
    @IBOutlet weak var itemLbl: UILabel!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var imgBgView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var cellBgView: UIView!
    @IBOutlet weak var leftView: UIView!
    // Shared offset to sync scrolling
       static var syncedOffset: CGPoint = .zero
    
    //MARK: VARIABLES
    var product: [Products]?{
        didSet{
            cellColl.reloadData()
        }
    }
    var productt: [Products]?{
        didSet{
            cellColl.reloadData()
        }
    }
    var shopSummry: [ShopSummary]?{
        didSet{
            cellColl.reloadData()
        }
    }
    var productName: String? {
        didSet {
            cellColl.reloadData()
        }
    }
    var shopImages = [ShopName]()
    var totalPrice = [Double]()
    override func awakeFromNib() {
        super.awakeFromNib()
        cellColl.delegate = self
        cellColl.dataSource = self
        // Register to listen to scroll updates from other cells
        NotificationCenter.default.addObserver(self, selector: #selector(syncCollectionViewScroll(_:)), name: NSNotification.Name("SyncScroll"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Sync scroll position
        @objc func syncCollectionViewScroll(_ notification: Notification) {
            if let offset = notification.object as? CGPoint, cellColl.contentOffset != offset {
                cellColl.setContentOffset(offset, animated: false)
            }
        }
    
    // UICollectionView scroll event
       func scrollViewDidScroll(_ scrollView: UIScrollView) {
           if scrollView is UICollectionView {
               ShoppingListTVC.syncedOffset = scrollView.contentOffset
               
               // Notify other cells to sync the scroll position
               NotificationCenter.default.post(name: NSNotification.Name("SyncScroll"), object: scrollView.contentOffset)
           }
       }
}

//MARK: EXTENSION COLLECTION VIEW
extension ShoppingListTVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0{
            return shopImages.count == 0 ? 5 : shopImages.count
        }else if itemLbl.text == "Total Basket".localized() {
            return (self.shopSummry?.count ?? 0) == 0 ? 5 : (self.shopSummry?.count ?? 0)
        }else{
            return product?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //MARK: - SET LOGO
        if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogoCVC", for: indexPath) as! LogoCVC

            if shopImages.count == 0 {
                cell.logoImg.isSkeletonable = true
                cell.logoImg.showAnimatedGradientSkeleton()

            } else {
                cell.logoImg.hideSkeleton()
                let image = (imageURL) + (shopImages[indexPath.row].image ?? "")

                cell.logoImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.logoImg.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder"))

            }
            return cell
        }
        
        //MARK: - TOTAL BASKET PRICE SET
        else if itemLbl.text == "Total Basket".localized() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PriceCVC", for: indexPath) as! PriceCVC
            if self.shopSummry?.count ?? 0 == 0 {


                cell.bgView.isSkeletonable = true
                cell.bgView.layer.cornerRadius = cell.bgView.frame.height / 2
                cell.bgView.clipsToBounds = true
                cell.bgView.showAnimatedGradientSkeleton()

                cell.lblBestPrice.isSkeletonable = true
                cell.lblBestPrice.showAnimatedGradientSkeleton()


            } else {
                cell.bgView.hideSkeleton()
                cell.lblBestPrice.hideSkeleton()
                let totalPrice = (self.shopSummry?[indexPath.row].totalPrice ?? 0)
                let nonZeroPrices = self.shopSummry?.compactMap { $0.totalPrice }.filter { $0 > 0 } ?? []
                let minPrice = nonZeroPrices.min() ?? 0
                
               

                if totalPrice == 0 {
                    cell.priceLbl.text = "-"
                } else {
                    let formatted = (totalPrice.truncatingRemainder(dividingBy: 1) == 0) ?
                        String(format: "%.0f", totalPrice) :
                        String(format: "%.2f", totalPrice).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
                    cell.priceLbl.text = formatted
                }
                
//                cell.priceLbl.text = (totalPrice == 0) ? "-" : (totalPrice.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", totalPrice) : String(format: "%.2f", totalPrice))

                if totalPrice > 0 && totalPrice == minPrice {
                    cell.bgView.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
                    cell.priceLbl.textColor = .white
                    cell.lblBestPrice.isHidden = false
                    cell.lblBestPrice.text = "Best Basket".localized()
                } else {
                    cell.bgView.backgroundColor = .clear
                    cell.priceLbl.textColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
                    cell.lblBestPrice.isHidden = true
                }
            }

            return cell
        }

        // MARK: - SET PRICE FOR PRODUCT
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PriceCVC", for: indexPath) as? PriceCVC else {
                return UICollectionViewCell()
            }
            guard let currentProduct = product?[indexPath.row] else {
                cell.priceLbl.text = "--"
                cell.bgView.backgroundColor = .clear
                cell.priceLbl.textColor = .black
                return cell
            }

            cell.bgView.hideSkeleton()
            cell.lblBestPrice.hideSkeleton()

            // Get matching shop for the product
            if let shopIndex = shopImages.firstIndex(where: { $0.id == currentProduct.shopName?.id }) {
                let image = (imageURL) + (shopImages[shopIndex].image ?? "")
                cell.bgView.backgroundColor = .clear
                let filterObj = product?.filter { $0.shopName?.name ?? "" == shopImages[shopIndex].name }
                let price = filterObj?.first?.price ?? 0
                
                // ✅ Show "--" if price is 0


                if price == 0 {
                    cell.priceLbl.text = "-"
                } else {
                    let formatted = (price.truncatingRemainder(dividingBy: 1) == 0) ?
                        String(format: "%.0f", price) :
                        String(format: "%.2f", price).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
                    cell.priceLbl.text = formatted
                }
//                cell.priceLbl.text = (price == 0) ? "-" : "\((price.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", price) : String(format: "%.2f", price)))"

                if let selectedProductName = productName {
                    let filteredProducts = product?.filter {
                        let currentLang = L102Language.currentAppleLanguageFull()
                        switch currentLang {
                        case "ar":
                            return $0.nameArabic == selectedProductName
                        default:
                            return $0.name == selectedProductName }
                    } ?? []


                    let minPrice = filteredProducts.min(by: { ($0.price ?? 0) < ($1.price ?? 0) })?.price ?? 0
                    
                    if currentProduct.price == minPrice && price != 0 {
                        // ✅ Highlight lowest price product
                        cell.bgView.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
                        cell.priceLbl.textColor = .white
                        // ✅ Show "Lowest Price\nBest Price"
                        cell.lblBestPrice.isHidden = false
                        cell.lblBestPrice.text = "Best Price".localized()
                        cell.priceLbl.numberOfLines = 0
                        cell.priceLbl.textAlignment = .center
                    } else {
                        cell.lblBestPrice.isHidden = true
                        cell.bgView.backgroundColor = .clear
                        cell.priceLbl.textColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
                    }
                }
            } else {
                // If no matching shop is found, show "--"
                cell.bgView.backgroundColor = .clear
                cell.priceLbl.text = "--"
                cell.priceLbl.textColor = .black
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cellColl.tag == 0 {
            return CGSize(width: cellColl.layer.bounds.width / 4, height: 40)
        } else {
            return CGSize(width: cellColl.layer.bounds.width / 4, height: 86)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}



extension Array where Element: Equatable {
    func removingDuplicates() -> [Element] {
        var uniqueElements = [Element]()
        for element in self {
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
        return uniqueElements
    }
}
