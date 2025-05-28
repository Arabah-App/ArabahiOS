//
//  popUpVC.swift
//  ARABAH
//
//  Created by cqlios on 06/11/24.
//

import UIKit

class popUpVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var NoBtn: CustomButton!
    @IBOutlet weak var YesBtn: UIButton!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var imgVie: UIImageView!
    @IBOutlet var lblHeader: UILabel!
    //MARK: - VARIABELS
    var check = ""
    var closure: (()->())?
    var viewModal = AuthViewModal()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        checkval()
        NoBtn.setLocalizedTitleButton(key: "No")
    }
    //MARK: - FUNCTION
    func checkval(){
        if check == "1" {
            lblHeader.text = "Sign Out".localized()
            lblDesc.text = "Are you sure you want to Sign Out?".localized()
            imgVie.image = UIImage(named: "logOut")
        } else if check == "2" {
            lblHeader.text = "Delete Account".localized()
            lblDesc.text = "Are you sure you want to delete your account?".localized()
            imgVie.image = UIImage(named: "deleteBtn")
        } else if check == "3"{
            lblHeader.text = "Clear Notification".localized()
            lblDesc.text = "Are you sure you want to clear all notifications?".localized()
            imgVie.image = UIImage(named: "deleteBtn")
        }else if check == "4"{
            lblHeader.text = "Delete Note".localized()
            lblDesc.text = "Are you sure you want to delete note?".localized()
            imgVie.image = UIImage(named: "deleteBtn")
        }else if check == "5"{
            lblHeader.text = "Delete Shopping List".localized()
            lblDesc.text = "Are you sure you want to delete this item?".localized()
            imgVie.image = UIImage(named: "deleteBtn")
        }else{
            lblHeader.text = "Remove Product".localized()
            lblDesc.text = "Are you sure you want to remove this product?".localized()
            imgVie.image = UIImage(named: "deleteBtn")
        }
    }
    func deleteAPI(){
        viewModal.deleteAccountAPI { dataa in
            let SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            Store.autoLogin = false
            Store.filterdata = nil
            Store.fitlerBrand = nil
            Store.filterStore = nil
            
            Store.authToken = nil
            Store.isfromsecure = ""
            let nav = UINavigationController.init(rootViewController: SignInViewController)
            nav.isNavigationBarHidden = true
            UIApplication.shared.windows.first?.rootViewController = nav
        }
    }
    func logOutAPI(){
        viewModal.logoutAPI { dataa in
            Store.filterdata = nil
            Store.fitlerBrand = nil
            Store.filterStore = nil
            Store.userDetails = nil
            Store.authToken = nil
            Store.autoLogin = false
            Store.isfromsecure = ""
            let SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC


            let nav = UINavigationController.init(rootViewController: SignInViewController)
            nav.isNavigationBarHidden = true
            UIApplication.shared.windows.first?.rootViewController = nav
        }
    }
    //MARK: - ACTIONS
    @IBAction func BtnYes(_ sender: UIButton) {
        if check == "1"{
            logOutAPI()
        }else if check == "2"{
            deleteAPI()
        }else if check == "3"{
            self.dismiss(animated: false) {
                self.closure?()
            }
        }else{
            self.dismiss(animated: false) {
                self.closure?()
            }
        }
    }
    @IBAction func BtnNo(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
