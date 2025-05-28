//
//  CommentTVC.swift
//  ARABAH
//
//  Created by cqlios on 25/10/24.
//

import UIKit
import SDWebImage

class CommentTVC: UITableViewCell {
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var viewMain: UIView!
    
    var setupObj:CommentElement?{
          didSet{
              let imageIndex = (imageURL) + (self.setupObj?.userID?.image ?? "")
              self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
              self.imgView.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
              self.lblDescription.text = self.setupObj?.comment ?? ""
              self.lblUserName.text = self.setupObj?.userID?.name ?? ""
          }
      }
    
}
