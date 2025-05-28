//
//  OfferTVC.swift
//  ARABAH
//
//  Created by cqlios on 24/10/24.
//

import UIKit

class OfferTVC: UITableViewCell {

    //MARK: OUTLETS
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var lblHighLowPrice : UILabel!
    @IBOutlet var viewMAin: UIView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var storeNameLbl: UILabel!
    var productUnit = String()
    var setupObj:HighestPriceProductElement?{
          didSet{
              
              let  minValue = (self.setupObj?.price ?? 0)
              
              if minValue == 0 {
                  priceLbl.text = "⃀ 0"
              } else {
                  let formatted = (minValue.truncatingRemainder(dividingBy: 1) == 0) ?
                      String(format: "%.0f", minValue) :
                      String(format: "%.2f", minValue).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
                  priceLbl.text = "⃀ \(formatted)"
              }
              
//              let val = (minValue == 0) ? "0" : (minValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", minValue) : String(format: "%.2f", minValue))
              
             // self.priceLbl.text = val
              //self.quantityLbl.text = self.productUnit
              self.quantityLbl.text = ""
            //  self.storeNameLbl.text = self.setupObj?.shopName?.name ?? ""

              if let imageName = self.setupObj?.shopName?.image {
                  let image = (imageURL) + (imageName)
                  if storeImage != nil {
                      storeImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder"))
                  }
              }
          }
      }
}
