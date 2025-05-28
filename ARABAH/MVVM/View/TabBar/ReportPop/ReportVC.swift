//
//  ReportVC.swift
//  ARABAH
//
//  Created by cqlios on 25/10/24.
//

import UIKit
import IQTextView

class ReportVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var txtView: IQTextView!
    @IBOutlet var viewMain: UIView!
    //MARK: - VARIABELS
    var viewModal = HomeViewModal()
    var productID = String()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        txtView.placeholder = "Write here...".localized()
        viewMain.layer.cornerRadius = 26
        viewMain.layer.masksToBounds = true
        viewMain.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    //MARK: - FUCNTION
    func reportAPI(){
        if Store.authToken == nil || Store.authToken == "" {
            self.authNil()
        } else {
            viewModal.reportAPI(ProductID: self.productID, message: self.txtView.text ?? "") { dataa in
                CommonUtilities.shared.showAlert(message: "Report Successfully".localized(), isSuccess: .success)
                self.dismiss(animated: true)
            
        }
        }
            
    }
    //MARK: - ACTIONS
    @IBAction func btnCross(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func BtnSubmit(_ sender: UIButton) {
        reportAPI()
    }
}
