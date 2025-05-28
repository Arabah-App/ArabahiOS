//
//  CheckValidations.swift
//  Schedula
//
//  Created by apple on 11/09/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit

import SwiftMessages
class CheckValidations: NSObject {
    class func validationSignUp(country_code: String, phone: String) -> Bool {
        if country_code.trimmingCharacters(in: .whitespaces).isEmpty {
            CommonUtilities.shared.showAlert(message: RegexMessages.invalidCountryCode, isSuccess: .error)
            return false
        }else if phone.trimmingCharacters(in: .whitespaces).isEmpty {
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyPhoneNumber, isSuccess: .error)
            return false
        }
//        } else if phone.count < getCountryBasedMobileNumberRange(code: country_code){
//            CommonUtilities.shared.showAlert(message: "Please enter valid mobile number.",isSuccess: .error)
//            return false
//        }
        return true
    }

    class func validateOtp(otp: String) -> Bool {
        if otp.count < 4 {
            CommonUtilities.shared.showAlert(message: "Please enter OTP", isSuccess: .error)
            return false
        }
        return true
    }

    class func validateEditProfile(name: String, fullname:String) -> Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyFirstName, isSuccess: .error)
            return false
        }else if !name.onlyAlphabet{
            CommonUtilities.shared.showAlert(message: RegexMessages.invalidFirstName, isSuccess: .error)
            return false
        }else if fullname.trimmingCharacters(in: .whitespaces).isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyLastName, isSuccess: .error)
            return false
        }else if !fullname.onlyAlphabet{
            CommonUtilities.shared.showAlert(message: RegexMessages.invalidLastName, isSuccess: .error)
            return false
        }
        return true
    }

    class func addticketvalidation(tittle:String, description:String) -> Bool{
        if tittle.trimmingCharacters(in: .whitespaces).isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.emptytittle, isSuccess: .error)
            return false
        }else if description.trimmingCharacters(in: .whitespaces).isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyDescription, isSuccess: .error)
            return false
        }
        return true
    }

    class func addressFill(name: String, housenumber:String, address:String) -> Bool {
        if address.trimmingCharacters(in: .whitespaces).isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyAddress, isSuccess: .error)
            return false
        }
        return true
    }
    
    class func completeProfile(name: String, email:String) -> Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyName,isSuccess: .error)
            return false
        }
//        else if email.trimmingCharacters(in: .whitespaces).isEmpty{
//            CommonUtilities.shared.showAlert(message: RegexMessages.emptyEmail, isSuccess: .error)
//            return false
//        }
        else if !Validation().validateEmailId(emailID: email) && !email.trimmingCharacters(in: .whitespaces).isEmpty {
            CommonUtilities.shared.showAlert(message: RegexMessages.invalidEmail, isSuccess: .error)
            return false
        }
        return true
    }
    
    class func addRaiting(Description: String) -> Bool {
        if Description.trimmingCharacters(in: .whitespaces).isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.invalidEmptyDescription, isSuccess: .error)
            return false
        }
        return true
    }
    
    class func ReportValidation(Description: String) -> Bool {
        if Description.trimmingCharacters(in: .whitespaces).isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.invalidEmptyDescription, isSuccess: .error)
            return false
        }
        return true
    }

    class func checkcardDAta(CardName: String,Cardnumber: String, Expierymonth: String,ExpiryYear:String, CVC: String ) ->Bool{
        if CardName.isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyCardName, isSuccess: .error)
            return false
        }else if Cardnumber.isEmpty {
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyCardNumber, isSuccess: .error)
            return false
        }else if Expierymonth.isEmpty {
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyExpiryMonth, isSuccess: .error)
            return false
        }else if ExpiryYear.isEmpty {
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyExpiryYear, isSuccess: .error)
            return false
        }else if CVC.isEmpty {
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyCVC, isSuccess: .error)
            return false
        }
        return true
    }

    class func ContactUs(firstName: String,Emial: String,message:String) ->Bool{
        if firstName.trimmingCharacters(in: .whitespaces).isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyName,isSuccess: .error)
            return false
        }else if !firstName.onlyAlphabet{
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyName,isSuccess: .error)
            return false
        }else if Emial.trimmingCharacters(in: .whitespaces).isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyEmail,isSuccess: .error)
            return false
        }else if !Validation().validateEmailId(emailID: Emial) {
            CommonUtilities.shared.showAlert(message: RegexMessages.invalidEmail, isSuccess: .error)
            return false
        }else if message.trimmingCharacters(in: .whitespaces).isEmpty{
            CommonUtilities.shared.showAlert(message: RegexMessages.emptyMessage,isSuccess: .error)
            return false
        }
        return true
    }

    class func validateHireRequest(addressId:String,date:String,time:String,description:String, images: [UIImage?], videos:[Data], type:Int) ->Bool{
        if type == 2 {
            if date.trimmingCharacters(in: .whitespaces).isEmpty{
                CommonUtilities.shared.showAlert(message: RegexMessages.invalidEmptyDate,isSuccess: .error)
                return false
            }
        }
        if time.trimmingCharacters(in: .whitespaces).isEmpty {
            CommonUtilities.shared.showAlert(message: RegexMessages.invalidEmptyTime,isSuccess: .error)
            return false
        }else if addressId.trimmingCharacters(in: .whitespaces).isEmpty {
            CommonUtilities.shared.showAlert(message: RegexMessages.invalidEmptyAddress,isSuccess: .error)
            return false
        }else if images.count < 2 {
            CommonUtilities.shared.showAlert(message: RegexMessages.imagesCount,isSuccess: .error)
            return false
        }else if images.count > 10{
            CommonUtilities.shared.showAlert(message: RegexMessages.imageLimitExceeds,isSuccess: .error)
            return false
        }else if description.trimmingCharacters(in: .whitespaces).isEmpty {
            CommonUtilities.shared.showAlert(message: RegexMessages.invalidEmptyAudio,isSuccess: .error)
            return false
        }
        return true
    }
}
