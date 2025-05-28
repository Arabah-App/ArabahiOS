//
//  FaqTVC.swift
//  Wimbo
//
//  Created by cqlnitin on 21/12/22.
//

import UIKit

class FaqTVC: UITableViewCell {

//     MARK: - OUTLET 
    @IBOutlet weak var lblBody: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var FaqHeadingLbl: UILabel!
    @IBOutlet weak var onClickBtn: UIButton!
    @IBOutlet weak var mainVw: CustomView!
    
    //     MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
