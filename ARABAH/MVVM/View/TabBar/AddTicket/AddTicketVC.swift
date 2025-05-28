//
//  AddTicketVC.swift
//  ARABAH
//
//  Created by cqlpc on 08/11/24.
//

import UIKit
import IQTextView

class AddTicketVC: UIViewController, UITextViewDelegate {

    //MARK: - OUTLETS
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTittle: UILabel!
    @IBOutlet var txtFldTittle: CustomTextField!
    @IBOutlet var txtViewDes: IQTextView!
    //MARK: - VARIABELS
    var viewModal = HomeViewModal()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        txtViewDes.placeholder = "Write here...".localized()
        if Store.isArabicLang == true{
            txtViewDes.textAlignment = .right
            txtFldTittle.textAlignment = .right
        }else{
            txtViewDes.textAlignment = .left
            txtFldTittle.textAlignment = .left
        }
    }
    //MARK: - FUNCTIONS
    func addTicketAPI(){
        viewModal.addTicketAPI(tittle: txtFldTittle.text ?? "", Description: txtViewDes.text ?? "") { dataa in
            self.navigationController?.popViewController(animated: true)
        }
    }
    //MARK: ACTIONS
    @IBAction func didTapSubmitBtn(_ sender: UIButton) {
        self.addTicketAPI()
    }
    
    @IBAction func didTapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
