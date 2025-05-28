//
//  TermsConditionVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit

class TermsConditionVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var txtView: UITextView!
    @IBOutlet var lblHeader: UILabel!
    //MARK: - VARIABLES
    var headerChagne = Int()
    var viewmodal = AuthViewModal()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        getcontent()
        if headerChagne == 1 {
            lblHeader.text = "About Us".localized()
        }else if headerChagne == 2 {
            lblHeader.text = "Privacy Policy".localized()
        }else{
            lblHeader.text = "Terms and Conditions".localized()
        }
    }
    func getcontent(){
        viewmodal.getPrivacyAPI(type: headerChagne) { dataa in
            self.txtView.text = dataa?.description?.htmlToString
        }
    }

    //MARK: - ACTIONS
    @IBAction func BtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
