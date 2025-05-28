//
//  OfferVC.swift
//  ARABAH
//
//  Created by cqlios on 25/10/24.
//

import UIKit

class OfferVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var offersTbl: UITableView!
    //MARK: - VARIABLES
    var product: [HighestPriceProductElement]?
    var productQty = String()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    //MARK: - ACTIONS
    @IBAction func didTapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - EXTENSION
extension OfferVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        product?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = offersTbl.dequeueReusableCell(withIdentifier: "OfferTVC", for: indexPath) as! OfferTVC
        let product = self.product?[indexPath.row]
        if product?.price == self.product?.map({ $0.price ?? 0 }).min() {
            cell.lblHighLowPrice.text = "Lowest Price".localized()
        } else if product?.price == self.product?.map({ $0.price ?? 0 }).max() {
            cell.lblHighLowPrice.text = "Highest Price".localized()
        } else {
            cell.lblHighLowPrice.text = ""
        }
        let minValue = product?.price ?? 0
//        let val = (minValue == 0) ? "0" : (minValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", minValue) : String(format: "%.2f", minValue))
//        
//        let  minValue = (self.setupObj?.price ?? 0)
        
        if minValue == 0 {
            cell.priceLbl.text = "⃀ 0"
        } else {
            let formatted = (minValue.truncatingRemainder(dividingBy: 1) == 0) ?
                String(format: "%.0f", minValue) :
                String(format: "%.2f", minValue).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
            cell.priceLbl.text = "⃀ \(formatted)"
        }
        
      //  cell.priceLbl.text = val
        cell.productUnit = self.productQty
      //  cell.storeNameLbl.text = product?.shopName?.name ?? ""
        if let imageName = product?.shopName?.image {
            let image = (imageURL) + (imageName)
            if cell.storeImage != nil {
                cell.storeImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder"))
            }
        }
        return cell
    }
}
