//
//  FavProductCVC.swift
//  ARABAH
//
//  Created by cql71 on 14/01/25.
//

import UIKit
import SDWebImage

class FavProductCVC: UICollectionViewCell {
    
    @IBOutlet weak var prodUnit: UILabel!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var ProdImg: UIImageView!
    @IBOutlet weak var btnFav: UIButton!
    
    var setupObj:LikeProductModalBody?{
        didSet{
            let imageIndex = (imageURL) + (self.setupObj?.productID?.image ?? "")
            self.ProdImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.ProdImg.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
            self.prodName.text = self.setupObj?.productID?.name ?? ""


            let data = self.setupObj?.productID?.product ?? []
            let newproduct = data.sorted(by: {$0.price ?? 0 < $1.price ?? 0})
            let prices = newproduct.map({$0.price ?? 0})
            let lowestPrice = prices.min() ?? 0
            
            let val = (lowestPrice == 0) ? "0" : (lowestPrice.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", lowestPrice) : String(format: "%.2f", lowestPrice))
            
            let currentLang = L102Language.currentAppleLanguageFull()
            switch currentLang {
            case "ar":
                self.prodPrice.text = "⃀ " + "\(val)" 
            default:
                self.prodPrice.text = "⃀" + "\(val)" }

//            let currentLang = L102Language.currentAppleLanguageFull()
//            switch currentLang {
//            case "ar":
//                self.prodPrice.text =  " \(self.setupObj?.productID?.price ?? "")" + "⃀ ".localized()
//            default:
//                self.prodPrice.text = "⃀ ".localized() + " \(self.setupObj?.productID?.price ?? "")" }

            //              self.prodUnit.text = self.setupObj?.productID?.prodiuctUnit ?? ""
            self.prodUnit.text = ""

        }
    }
}
