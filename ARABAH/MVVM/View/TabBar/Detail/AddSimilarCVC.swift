//
//  AddSimilarCVC.swift
//  ARABAH
//
//  Created by cqlpc on 07/11/24.
//

import UIKit
import SDWebImage

class AddSimilarCVC: UICollectionViewCell {
    
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblGmMl: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    var setupObj:SimilarProduct?{
        didSet{
            let imageIndex = (imageURL) + (self.setupObj?.image ?? "")
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgView.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
//            self.lblPrice.text = "⃀ ".localized() +
            self.lblProduct.text = self.setupObj?.name ?? ""

            
            let  minValue = ((self.setupObj?.product ?? []).compactMap({$0.price}).min() ?? 0)
            let val = (minValue == 0) ? "0" : (minValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", minValue) : String(format: "%.2f", minValue))
            
            self.lblGmMl.text = val
//            self.lblGmMl.text = " \(((self.setupObj?.product ?? []).compactMap({$0.price}).min() ?? 0).formatted())/" + "\(self.setupObj?.productUnitId?.prodiuctUnit ?? "")"
        }
    }
}

