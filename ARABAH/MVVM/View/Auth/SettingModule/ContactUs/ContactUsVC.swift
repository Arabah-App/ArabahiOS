//
//  ContactUsVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit
import IQTextView

class ContactUsVC: UIViewController, UITextViewDelegate {
    //MARK: - OUTLETS
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet var txtView: IQTextView!
    @IBOutlet var txtFldEmail: CustomTextField!
    @IBOutlet var viewMsg: UIView!
    @IBOutlet var txt: CustomTextField!
    //MARK: - VARIABELS
    var viewModal = AuthViewModal()
    let placeholderText = "Write here..."
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        lblName.setLocalizedTitle(key: "Name")
        txtView.placeholder = "Write here...".localized()
        lblEmail.text = "Email".localized()
        lblMessage.text = "Message".localized()
        if Store.isArabicLang == true{
            txtFldEmail.textAlignment = .right
            txt.textAlignment = .right
            txtView.textAlignment = .right
        }else{
            txtFldEmail.textAlignment = .left
            txt.textAlignment = .left
            txtView.textAlignment = .left
        }
    }
   
    //MARK: - FUNCTION
    func contactUsAPI(){
        viewModal.contactUsAPI(name: self.txt.text ?? "" , email: self.txtFldEmail.text ?? "", message: self.txtView.text ?? "") { dataa in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - ACTIONS
    @IBAction func BtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func BtnUpdate(_ sender: UIButton) {
        self.contactUsAPI()
    }
}

