//
//  ProfileTVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit

class ProfileTVC: UITableViewCell {
    
    //MARK: OUTLETS
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var viewBottom: UIView!
    @IBOutlet var btnOnOff: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: ACTIONS
    @IBAction func btnToggle(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
}
