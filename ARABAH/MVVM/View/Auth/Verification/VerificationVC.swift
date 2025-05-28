//
//  VerificationVC.swift
//  ARABAH
//
//  Created by cqlios on 18/10/24.
//

import UIKit

//txtFldOne
class VerificationVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var verifyBtn: UIButton!
    
    @IBOutlet weak var labelOTP: UILabel!
    @IBOutlet var txtFldCollection: [OtpTextField]!
    @IBOutlet var lblNumber: UILabel!
    @IBOutlet weak var viewFour: UIView!
    @IBOutlet weak var viewThree: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewOne: UIView!
    //MARK: - VARIABELS
    var otp = ""
    var number = ""
    var countryCode = ""
    var phoneCounty = ""
    var viewModal = AuthViewModal()
    var timer: Timer?
        var remainingSeconds = 300
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setCornerView()
        resendBtn.setLocalizedTitleButton(key: "Resend")
        self.phoneCounty = self.countryCode + self.number
        self.lblNumber.text = NSLocalizedString("Enter the 4-digit code sent to you at ", comment: "") + "\(self.countryCode)" + " \(self.number)"
//        CommonUtilities.shared.showAlert(message: "Please enter static OTP 1111".localized(), isSuccess: .success)
    }
    //MARK: - ACTIONS
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnVerify(_ sender: UIButton) {
        self.apiVerifyCall()
    }
    @IBAction func btnResend(_ sender: UIButton) {
        self.resentAPICall()
    }
    //MARK: - FUCNTIONS
    func setCornerView(){
        viewOne.layer.borderColor = UIColor.systemGray4.cgColor
        viewOne.layer.borderWidth = 1
        viewTwo.layer.borderColor = UIColor.systemGray4.cgColor
        viewTwo.layer.borderWidth = 1
        viewThree.layer.borderColor = UIColor.systemGray4.cgColor
        viewThree.layer.borderWidth = 1
        viewFour.layer.borderColor = UIColor.systemGray4.cgColor
        viewFour.layer.borderWidth = 1
        for tfs in txtFldCollection {
            tfs.backspaceDelegate = self
        }
    }

//    func apiVerifyCall() {
//        otp = txtFldCollection.map { $0.text ?? "" }.joined()
//        
//        if otp.isEmpty || otp.count < txtFldCollection.count {
//            CommonUtilities.shared.showAlert(message: "Please enter all OTP digits", isSuccess: .error)
//            return
//        } else {
//            viewModal.otpVerificatonAPI(otp: self.otp, phoneNnumberWithCode: self.phoneCounty) { dataa, message in
//                
//                DispatchQueue.main.async {
//                    if message == "Please enter valid OTP" || message == "الرجاء إدخال OTP صالح" {
//                        self.txtFldCollection.forEach { textField in
//                            textField.text = ""
//                        }
//                        self.txtFldCollection.first?.becomeFirstResponder() // Move focus to first field
//                    } else {
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
//                        Store.autoLogin = true
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
//                }
//            }
//        }
//    }
    func apiVerifyCall() {
        otp = txtFldCollection.map { $0.text ?? "" }.joined()
        
        if otp.isEmpty || otp.count < txtFldCollection.count {
            CommonUtilities.shared.showAlert(message: "Please enter all OTP digits", isSuccess: .error)
            return
        }

        viewModal.otpVerificatonAPI(otp: self.otp, phoneNnumberWithCode: self.phoneCounty) { data, message in
            DispatchQueue.main.async {
                if message == "Please enter valid OTP" || message == "الرجاء إدخال OTP صالح" || message == "API call failed. Please try again." {
                    // Clear OTP fields if API fails or OTP is invalid
                    self.txtFldCollection.forEach { $0.text = "" }
                    self.txtFldCollection.first?.becomeFirstResponder()
                } else {
                    // Navigate to next screen on success
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
                        Store.autoLogin = true
                        
                        // Create a new navigation controller with the new view controller as the root
                        let newNavigationController = UINavigationController(rootViewController: vc)
                        newNavigationController.isNavigationBarHidden = true
                        
                        // Replace the root view controller with the new navigation controller
                        if let window = UIApplication.shared.keyWindow {
                            window.rootViewController = newNavigationController
                            window.makeKeyAndVisible()
                        }
                    }
                }
            }
        }
    }


    func resentAPICall(){
        viewModal.resendOtpAPI(phone: self.phoneCounty) {
            self.startOTPTimer()
//            CommonUtilities.shared.showAlert(message: "Please enter static OTP 1111".localized(), isSuccess: .success)
        }
    }

    func startOTPTimer() {
        remainingSeconds = 300
        resendBtn.isEnabled = false
        updateButtonTitle()

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc func updateTimer() {
         if remainingSeconds > 0 {
             remainingSeconds -= 1
             updateButtonTitle()
         } else {
             timer?.invalidate()
             labelOTP.text = ""
             resendBtn.isEnabled = true
         }
     }

     func updateButtonTitle() {
         let minutes = remainingSeconds / 60
         let seconds = remainingSeconds % 60
         labelOTP.text = String(format: "%02d:%02d", minutes, seconds)
     }
}
//MARK: - EXTENSIONS
extension VerificationVC: UITextFieldDelegate, BackspaceTextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        
        // Allow only single character input
        if string.count > 1 { return false }
        
        // OTP Fields navigation logic
        if string.isEmpty { // Backspace handling
            textField.text = ""
            if let index = txtFldCollection.firstIndex(of: textField as! OtpTextField), index > 0 {
                txtFldCollection[index - 1].becomeFirstResponder()
            }
            return false
        } else { // Forward movement
            textField.text = string
            if let index = txtFldCollection.firstIndex(of: textField as! OtpTextField), index < txtFldCollection.count - 1 {
                txtFldCollection[index + 1].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
                checkAndVerifyOTP() // ✅ API Call on 4th Digit Entry
            }
            return false
        }
    }
    
    func checkAndVerifyOTP() {
        otp = txtFldCollection.map { $0.text ?? "" }.joined()
        if otp.count == 4 {
            apiVerifyCall()
        }
    }
    
    func textFieldDidDelete(_ textField: OtpTextField) {
        if let index = txtFldCollection.firstIndex(of: textField), index > 0 {
            txtFldCollection[index - 1].becomeFirstResponder()
        }
    }
}
