
//
//  ProfileVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit
import SDWebImage

class ProfileVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var lblCountyPhone: UILabel!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var tblVw: UITableView!
    //MARK: - VARIABELS

    let header = ["Price Notifications".localized(),"Raise Ticket".localized(),"Favourite Product".localized(), "Change Language".localized(), "Notes".localized(), "Terms and Conditions".localized(), "Privacy Policy".localized(), "About Us".localized(), "Contact Us".localized(), "Faq".localized(), "Sign Out".localized(), "Delete Account".localized()]
    let imgary = ["notification", "ticket", "heart", "Layer 2", "notes-2", "document", "Group 38144", "info", "contact-mail", "Qutions", "exit", "Image 59" ]
    var checkVal = ""
    var viewmodal = AuthViewModal()

    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authNil(val: true)
        
        if let userData = Store.userDetails?.body {
            if userData.image != "" && userData.name != "" && userData.email != "" {
                self.btnComplete.setTitle(NSLocalizedString("Edit Profile", comment: ""),for: .normal)
            } else {
                self.btnComplete.setTitle(NSLocalizedString("Complete Your Profile", comment: ""),for: .normal)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let userData = Store.userDetails?.body {
            let profile = (imageURL) + (userData.image ?? "")
            self.profileImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImg.sd_setImage(with: URL(string: profile), placeholderImage: UIImage(named: "Placeholder"))
            self.lblUser.text = userData.name ?? ""
            self.lblCountyPhone.text = "\(userData.countryCode ?? "") " + "\(userData.phone ?? "")"

            if userData.image != "" && userData.name != "" && userData.email != "" {
                self.btnComplete.setTitle(NSLocalizedString("Edit Profile", comment: ""),for: .normal)
            }else{
                self.btnComplete.setTitle(NSLocalizedString("Complete Your Profile", comment: ""),for: .normal)
            }
        }
    }

    //MARK: - ACTIONS
    @IBAction func BtnEditProfile(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: - FUNCTIONS
    func getProfile(){
        viewmodal.getProfileAPI { dataa in
            self.btnComplete.isHidden = false
            let profile = (imageURL) + (dataa?.image ?? "")
            self.profileImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImg.sd_setImage(with: URL(string: profile), placeholderImage: UIImage(named: "Placeholder"))
            self.lblUser.text = dataa?.name ?? ""
            self.lblCountyPhone.text = "\(dataa?.countryCode ?? "") " + "\(dataa?.phone ?? "")"
            if dataa?.image != "" && dataa?.name != "" && dataa?.email != "" {
                self.btnComplete.setTitle(NSLocalizedString("Edit Profile", comment: ""),for: .normal)
            }else{
                self.btnComplete.setTitle(NSLocalizedString("Complete Your Profile", comment: ""),for: .normal)
            }
        }
    }
}
//MARK: - EXTENSIONS
extension ProfileVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return header.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVC", for: indexPath) as! ProfileTVC
        if Store.isArabicLang == true{
            cell.btnNext.setImage(UIImage(named: "ic_next_screen 1"), for: .normal)
        }else{
            cell.btnNext.setImage(UIImage(named: "ic_next_screen"), for: .normal)
        }
        cell.lblHeading.text = NSLocalizedString(header[indexPath.row], comment: "")
        cell.btnOnOff.addTarget(self, action: #selector(selectBtn(_:)), for: .touchUpInside)
        cell.imgView.image = UIImage(named: imgary[indexPath.row])
        if indexPath.row == 0{
            cell.btnOnOff.isSelected = (Store.userDetails?.body?.isNotification ?? 1 == 1)
//            cell.btnOnOff.setImage(Store.userDetails?.body?.isNotification ?? 1 == 1 ? UIImage(named: ImageNames.buttonOn) : UIImage(named: ImageNames.buttonOff), for: .normal)
            //cell.btnOnOff.isSelected = Store.userDetails?.body?.isNotification ?? 1 == 1 ? true : false
            cell.btnNext.isHidden = true
            cell.btnOnOff.isHidden = false
            cell.viewBottom.isHidden = true
            cell.lblHeading.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }else if indexPath.row == 11 {
            cell.btnNext.isHidden = true
            cell.btnOnOff.isHidden = true
            cell.viewBottom.isHidden = true
            cell.lblHeading.textColor = #colorLiteral(red: 0.7882352941, green: 0.2039215686, blue: 0.2039215686, alpha: 1)
        } else if indexPath.row == 10 {
            cell.btnNext.isHidden = true
            cell.btnOnOff.isHidden = true
            cell.viewBottom.isHidden = true
            cell.lblHeading.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }else if indexPath.row == 2 || indexPath.row == 9 {
            cell.btnOnOff.isHidden = true
            cell.viewBottom.isHidden = false
            cell.lblHeading.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }else{
            cell.viewBottom.isHidden = true
            cell.btnNext.isHidden = false
            cell.btnOnOff.isHidden = true
            cell.lblHeading.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        return cell
    }
    //MARK: OBJC FUNCTIONS
    @objc func selectBtn(_ sender:UIButton){
        let notificationStatus = Store.userDetails?.body?.isNotification == 1 ? 0 : 1
        let successMsg = notificationStatus == 1 ? "Notification status On successfully".localized() : "Notification status Off successfully".localized()
        
        viewmodal.notificationOnOffAPI(isstatus: notificationStatus) { [weak self] dataa in
            guard let self = self else { return }
            Store.userDetails?.body?.isNotification = notificationStatus
            CommonUtilities.shared.showAlert(message: successMsg, isSuccess: .success)
            self.tblVw.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
        }else if indexPath.row == 1 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "RaiseTicketVC") as! RaiseTicketVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 2 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "FavProductVC") as! FavProductVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 3 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeLangVC") as! ChangeLangVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 4{
            let vc = storyboard?.instantiateViewController(withIdentifier: "NotesListingVC") as! NotesListingVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 5 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "TermsConditionVC") as! TermsConditionVC
            vc.headerChagne = 3
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 6 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "TermsConditionVC") as! TermsConditionVC
            vc.headerChagne = 2
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 7 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "TermsConditionVC") as! TermsConditionVC
            vc.headerChagne = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 8 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 9 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "FaqVC") as! FaqVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 10 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "popUpVC") as! popUpVC
            vc.modalPresentationStyle = .overCurrentContext
            vc.check = "1"
            vc.closure = {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let main = MainNavigationController(rootViewController: vc)
                main.isNavigationBarHidden = true
                UIApplication.shared.windows.first?.rootViewController = main
                
            }
            vc.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(vc, animated: false)
        }else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "popUpVC") as! popUpVC
            vc.check = "2"
            vc.closure = {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let main = MainNavigationController(rootViewController: vc)
                main.isNavigationBarHidden = true
                UIApplication.shared.windows.first?.rootViewController = main
            }
            vc.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(vc, animated: false)
        }
    }
}
