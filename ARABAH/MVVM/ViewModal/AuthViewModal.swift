//
//  AuthViewModal.swift
//  ARABAH
//
//  Created by cqlios on 09/12/24.
//

import Foundation
import UIKit

class AuthViewModal : NSObject{

    //MARK: - LOGIN PHONE API
    func loginPhoneAPI(country_code:String,phone:String,onSuccess:@escaping((LoginModalBody?)->())){
        if CheckValidations.validationSignUp(country_code: country_code, phone: phone){
            let parms = ["countryCode":country_code,"phone":phone, "deviceToken":Store.deviceToken ?? "","deviceType":1] as [String:Any]
            WebService.service(API.Signup, param: parms, service: .post) { (modalData:LoginModal, data, json) in
                Store.userDetails = modalData
                Store.authToken = modalData.body?.authToken
                onSuccess(modalData.body)
            }
        }
    }
    //MARK: - OTP VERFICATION API
    func otpVerificatonAPI(otp: String, phoneNnumberWithCode: String, onSuccess: @escaping ((LoginModalBody?, String?) -> ())) {
        if CheckValidations.validateOtp(otp: otp) {
            let parms: [String: Any] = [
                "otp": otp,
                "phoneNnumberWithCode": phoneNnumberWithCode,
                "deviceType": 1,
                "deviceToken": Store.deviceToken ?? ""
            ]
            
            WebService.service(API.verifyOtp, param: parms, service: .post) { (modalData: LoginModal?, data, json) in
                if let modalData = modalData {
                    Store.userDetails = modalData
                    Store.authToken = modalData.body?.token
                    onSuccess(modalData.body, modalData.message)
                } else {
                    onSuccess(nil, "API call failed. Please try again.")  // Handle API failure case
                }
            }
        } else {
            onSuccess(nil, "Invalid OTP format.") // Handle validation failure case
        }
    }
    //MARK: - RESENT OTP API
    func resendOtpAPI(phone:String,onSuccess:@escaping(()->())){
        let param = ["phonenumber":phone] as [String:Any]
        WebService.service(API.resentOtp,param: param, service: .post, showHud: true){
            (userData: LoginModal, data , json) in
            onSuccess()
        }
    }
    // MARK: - Notification LIST API
    func getNotificationList(onSuccess:@escaping(([GetNotificationModalBody]?)->())){
        WebService.service(API.Getnotification,service: .get) { (modelData : GetNotificationModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    // MARK: - Notification Delete API
    func notificationDeleteAPI(onSuccess:@escaping((NewCommonStringBody?)->())){
        WebService.service(API.deeletNotifiction,service: .post) { (modelData : NewCommonString, data, json) in
            onSuccess(modelData.body)
        }
    }
    

    // MARK: - COMPLETE PROFILE API
    func completeProAPI(name:String,email:String,image:UIImage,onSuccess:@escaping((LoginModalBody?)->())) {
        if CheckValidations.completeProfile(name: name, email: email){
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat.fulldate.rawValue
            let date = formatter.string(from: Date())
            let imageInfo : ImageStructInfo
            imageInfo = ImageStructInfo.init(fileName: "Img\(date).jpeg", type: "jpeg", data: image.toData() , key: "image")
            let param = ["name":name,"email":email,"image":imageInfo] as [String:Any]
            WebService.service(API.CompleteProfile,param: param,service: .post) { (modelData : LoginModal, data, json) in
                Store.userDetails = modelData
                onSuccess(modelData.body)
            }
        }
    }

    // MARK: - Notification LIST API
    func deleteAccountAPI(onSuccess:@escaping((LoginModalBody?)->())){
        WebService.service(API.DeleteAccount,service: .post) { (modelData : LoginModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    // MARK: - Get rating & review API
    func raitingListAPI(productId:String,onSuccess:@escaping((  GetRaitingModalBody?)->())){
        let param = ["productId":productId]
        WebService.service(API.RatingList,param: param,service: .get) { (modelData : GetRaitingModal, data, json) in
            onSuccess(modelData.body)
        }
    }
        
    //MARK: - ADD COMMENT API
    func addCommentAPI(productId:String,comment:String ,onSuccess:@escaping((AddCommentModalBody?)->())) {
        let param = ["ProductID":productId,"comment":comment]
        WebService.service(API.CreateComment,param: param,service: .post) { (modelData : AddCommentModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - CREATE RATING API
    func createRatingAPI(productId:String,rating:Double,review:String ,onSuccess:@escaping((AddCommentModalBody?)->())) {
        if CheckValidations.addRaiting(Description: review){
            let param = ["ProductID":productId,"rating":rating, "review":review] as [String:Any]
            WebService.service(API.CreateRating,param: param,service: .post) { (modelData : AddCommentModal, data, json) in
                onSuccess(modelData.body)
            }
        }
    }
    
    //MARK: - GET CONTENT FOR CMS API
    func getPrivacyAPI(type:Int,onSuccess:@escaping((TermsPrivacyMdoalBody?)->())) {
        let param = ["type":type] as [String:Any]
        WebService.service(API.CMSGet, param: param,service: .get) { (modelData : TermsPrivacyMdoal, data, json) in
            onSuccess(modelData.body)
        }
    }
    //MARK: - Product Detail API
    func prodcutDetailAPI(id:String,onSuccess:@escaping((ProductDetailModalBody?)->())) {
        let param = ["id":id] as [String:Any]
        WebService.service(API.ProductDetail, param: param,service: .get) { (modelData : ProductDetailModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Product Detail API
    func prodcutDetailAPIByQrCode(id:String,onSuccess:@escaping((ProductDetailModalBody?)->())) {
        let param = ["barcode":id] as [String:Any]
        WebService.service(API.barCodeDetail, param: param,service: .get) { (modelData : ProductDetailModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Notification on off API
    func notificationOnOffAPI(isstatus:Int,onSuccess:@escaping((LoginModalBody?)->())) {
        let param = ["IsNotification":isstatus] as [String:Any]
        WebService.service(API.PriceNotification, param: param,service: .put) { (modelData : LoginModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - CONTACT US API
    func contactUsAPI(name:String,email:String,message:String,onSuccess:@escaping((ContactUsModalBody?)->())) {
        if CheckValidations.ContactUs(firstName: name, Emial: email, message: message){
            let param = ["name":name, "email":email, "message":message] as [String:Any]
            WebService.service(API.CraeteContact, param: param,service: .post) { (modelData : ContactUsModal, data, json) in
                showSwiftyAlert("", modelData.message ?? "", true)
                onSuccess(modelData.body)
            }
        }
    }
    
    //MARK: - Get Profile API
    func getProfileAPI(onSuccess:@escaping((LoginModalBody?)->())) {
        WebService.service(API.Get_profile,service: .get) { (modelData : LoginModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - Get Fav Product list API
    func getProductfavList(onSuccess:@escaping(([LikeProductModalBody]?)->())) {
        WebService.service(API.ProductLike_list,service: .get) { (modelData : LikeProductModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    //MARK: - Get Faq list API
    func getFaqListAPi(onSuccess:@escaping(([FaqModalBody]?)->())) {
        WebService.service(API.FaQApi,service: .get) { (modelData : FaqModal, data, json) in
            onSuccess(modelData.body)
        }
    }
    
    //MARK: - LOGOUT API
    func logoutAPI(onSuccess:@escaping((LoginModalBody?)->())) {
        WebService.service(API.logOut,service: .post) { (modelData : LoginModal, data, json) in
            CommonUtilities.shared.showAlert(message: "User logOut successfully".localized(),isSuccess: .success)
            Store.remove = .userDetails
            Store.remove = .authKey
            Store.autoLogin = false
            onSuccess(modelData.body)
        }
    }
}
