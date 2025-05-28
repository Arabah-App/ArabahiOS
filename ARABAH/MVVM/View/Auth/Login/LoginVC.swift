//
//  LoginVC.swift
//  ARABAH
//
//  Created by cqlios on 18/10/24.
//

import UIKit
import CountryPickerView

class LoginVC: UIViewController{
    //MARK: - OUTLETS
    @IBOutlet var txtPhoneNumber: UITextField!
    @IBOutlet var ViewMain: UIView!
    @IBOutlet var contryImg: UIImageView!
    @IBOutlet var countryCode: UILabel!
    //MARK: - VARIABELS
    let cntrypicker = CountryPickerView()
    var countryCheck = String()
    var viewModal = AuthViewModal()
    var otp = String()
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if Store.isArabicLang == true{
            txtPhoneNumber.textAlignment = .right
        }else{
            txtPhoneNumber.textAlignment = .left
        }
        setUI()
    }
    
    //MARK: - ACTIONS
    @IBAction func btnAsGuest(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnSignIn(_ sender: UIButton) {
        callAPI()
    }
    @IBAction func btnCountry(_ sender: UIButton) {
        cntrypicker.showCountriesList(from: self)
    }

    //MARK: - FUNCTIONS
    func callAPI() {
        viewModal.loginPhoneAPI(country_code: countryCode.text ?? "", phone: txtPhoneNumber.text ?? "") { dataa in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerificationVC") as! VerificationVC
            vc.number = self.txtPhoneNumber.text ?? ""
            vc.countryCode = self.countryCode.text ?? ""
            vc.otp = "\(dataa?.otp ?? 0)"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - Extensions CountryPickerViewDelegate
extension LoginVC: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.countryCode.text = country.phoneCode
        self.contryImg.image = country.flag
    }
}

//MARK: TEXT FIELD DELEGATE
extension LoginVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 12 // Set your desired limit here
        let currentString: NSString = txtPhoneNumber.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

//MARK: FUNCTIONS
extension LoginVC {
    func setUI() {
        UserDefaults.standard.setValue(1, forKey: "Installed")
        txtPhoneNumber.delegate = self
        cntrypicker.delegate = self
        ViewMain.layer.borderWidth = 1
        ViewMain.layer.borderColor = UIColor.systemGray4.cgColor
        let currentCountry = cntrypicker.getCountryByCode(Locale.current.regionCode ?? "US")
        countryCode.text = currentCountry?.phoneCode
        contryImg.image = currentCountry?.flag
    }
}
