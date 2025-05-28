//
//  AddReviewVC.swift
//  ARABAH
//
//  Created by cqlios on 29/10/24.
//

import UIKit
import Cosmos

class AddReviewVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet var txtView: UITextView!
    @IBOutlet var viewTxtView: UIView!
    //MARK: - VARIABLES
    var viewmodal = AuthViewModal()
    var productID = String()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    //MARK: - FUNCTIONS
    func addComment(){
        viewmodal.createRatingAPI(productId: self.productID, rating: Double(ratingView.rating) , review: self.txtView.text ?? "") { dataa in
            self.navigationController?.popViewController(animated: true)
        }
    }
    //MARK: - ACTIONS
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSubmit(_ sender: UIButton) {
        addComment()
    }
}
