//
//  CommentAllTVC.swift
//  ARABAH
//
//  Created by cql71 on 09/01/25.
//

import UIKit
import SDWebImage

class CommentAllTVC: UITableViewCell {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    var setupObj:CommentElement?{
          didSet{
              let imageIndex = (imageURL) + (self.setupObj?.userID?.image ?? "")
              self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
              self.imgView.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
              self.lblDescription.text = self.setupObj?.comment ?? ""
              self.lblName.text = self.setupObj?.userID?.name ?? ""
          }
      }
}
