//
//  EditProfileVC.swift
//  ARABAH
//
//  Created by cqlios on 05/11/24.
//

import UIKit
import CountryPickerView
import SDWebImage

class EditProfileVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var txtFldEmail: CustomTextField!
    @IBOutlet var txtFldName: CustomTextField!
    @IBOutlet var viewDotBorder: UIView!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var countryImg: UIImageView!
    @IBOutlet var coutryCode: UILabel!
    @IBOutlet weak var numberTF: UITextField!
    //MARK: - VARIABELS
    let cntrypicker = CountryPickerView()
    var viewModal = AuthViewModal()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if Store.isArabicLang == true {
            txtFldName.textAlignment = .right
            txtFldEmail.textAlignment = .right
            numberTF.textAlignment = .right
        } else {
            txtFldName.textAlignment = .left
            txtFldEmail.textAlignment = .left
            numberTF.textAlignment = .left
        }

        numberTF.isUserInteractionEnabled = false
        cntrypicker.delegate = self
        cntrypicker.dataSource = self
        imgView.layer.cornerRadius = imgView.frame.size.width / 2
        if let userData = Store.userDetails?.body {
            let profile = (imageURL) + (userData.image ?? "")
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgView.sd_setImage(with: URL(string: profile), placeholderImage: UIImage(named: "Placeholder"))
            self.txtFldName.text = userData.name ?? ""
            self.txtFldEmail.text = userData.email ?? ""
            self.numberTF.text = Store.userDetails?.body?.phone ?? ""
            let defaultCntry = cntrypicker.getCountryByPhoneCode(userData.countryCode ?? "")
            countryImg.image = defaultCntry?.flag
            coutryCode.text = defaultCntry?.phoneCode
        }
    }

    //MARK: - FUNCTION
    func completeProfile() {
        viewModal.completeProAPI(name: self.txtFldName.text ?? "", email: self.txtFldEmail.text ?? "", image: self.imgView.image ?? UIImage()) { dataa in
            CommonUtilities.shared.showAlert(message: "Profile Updated Successfully".localized(), isSuccess: .success)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
//    //MARK: - GET PROFILE API
//    func getProfile(){
//        viewModal.getProfileAPI { dataa in
//            let profile = (imageURL) + (dataa?.image ?? "")
//            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//            self.imgView.sd_setImage(with: URL(string: profile), placeholderImage: UIImage(named: "Placeholder"))
//            self.txtFldName.text = dataa?.name ?? ""
//            self.txtFldEmail.text = dataa?.email ?? ""
//            self.numberTF.text = Store.userDetails?.body?.phone ?? ""
//            
//        }
//    }

    //MARK: - ACTIONS
    @IBAction func btnCountry(_ sender: UIButton) {
       // cntrypicker.showCountriesList(from: self)
    }
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnCamera(_ sender: UIButton) {
        ImagePickerManager().pickImage(self) { image in
            self.imgView.image = image
        }
    }
    @IBAction func btnSubmit(_ sender: UIButton) {
        completeProfile()
    }
    @IBAction func didTapImgPickerBtn(_ sender: UIButton) {
        ImagePickerManager().pickImage(self) { image in
            self.imgView.image = image
            self.imgView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 17)
            self.imgView.contentMode = .scaleAspectFill
        }
    }
}
extension UIView {
    func addDottedBorder(cornerRadius: CGFloat) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
        shapeLayer.lineWidth = 3 // Border thickness
        shapeLayer.lineDashPattern = [3, 3] // Pattern of dashes and gaps
        shapeLayer.fillColor = nil // Keep the background color transparent
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true // Ensures the corner radius is clipped
        self.layer.addSublayer(shapeLayer)
    }
}
//MARK: - Extensions CountryPickerViewDelegate
extension EditProfileVC: CountryPickerViewDelegate, CountryPickerViewDataSource {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.coutryCode.text = country.phoneCode
        self.countryImg.image = country.flag
    }
}

//MARK: TEXT FIELD DELEGATE
extension EditProfileVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 12
        let currentString: NSString = numberTF.text! as NSString
        let newString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
