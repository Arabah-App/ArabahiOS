//
//  Constants.swift
//  Reservine
//
//  Created by mac on 18/03/2020.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

public typealias parameters = [String:Any]

var appName = "Service Near"
typealias successResponse = (()->())

let googlePlacesApiKey = "AIzaSyBroQHNDgsO05eS9tiFmhU-VSIz4fJftmQ"
//LocalURL  :-  http://192.168.1.167:7000/api/
//BaseURL   :-   http://122.176.141.23:7000/api/
//ClientURL :- https://app.arabahtheapp.com/api
let baseURL                     = "https://admin.arabahtheapp.com/api/"
let imageURL                    = "https://admin.arabahtheapp.com"
let applicationDelegate         =  UIApplication.shared.delegate as! AppDelegate
var noInternetConnection        =  "No Internet Connection Available"

let SECRET_KEY = "2bfdb99389a53941f85307af2ea2651a6c97ee33cef1bf69107ff9cee70016c0"
let PUBLISH_KEY = "911a408834cab595756ad4244ed51fc0e227a657d9b418326f192030a78cec69"
let language_type = "en"
let device_type = "2"
var device_Token = "abc"
let userRole = 1

enum API: String {
    case Signup                 = "Signup"
    case verifyOtp              = "verifyOtp"
    case resentOtp              = "resent_otp"
    case CMSGet                 = "CMSGet"
    case ProductDetail          = "ProductDetail"
    case home                   = "home"
    case ApplyFilletr           = "ApplyFilletr"
    case PriceNotification      = "PriceNotification"
    case SubCategoryProduct     = "SubCategoryProduct"
    case ReportCreate           = "ReportCreate"
    case ShoppingProduct_delete = "ShoppingProduct_delete"
    case Notifyme               = "Notifyme"
    case NotesCreate            = "NotesCreate"
    case deleteNotes            = "deleteNotes"
    case changeLanguage         = "changeLanguage"
    case getNotes               = "getNotes"
    case Notes                  = "Notes"
    case getNotesdetail         = "getNotesdetail"
    case CreateSerach           = "CreateSerach"
    case SearchList             = "SearchList"
    case SerachDelete           = "SerachDelete"
    case SearchchingList        = "searchfilter"
    case categoryFilter         = "categoryFilter"
    case LatestProduct          = "LatestProduct"
    case createTicket           = "createTicket"
    case addShooping            = "AddtoShoppinglist"
    case ShoppingList           = "ShoppingList"
    case similarProducts        = "similarProducts"
    case ShoppinglistClear      = "ShoppinglistClear"
    case CreateComment          = "CreateComment"
    case CreateRating           = "CreateRating"
    case RatingList             = "RatingList"
    case TicketList             = "TicketList"
    case DealListing            = "DealListing"
    case ProductLike            = "ProductLike"
    case Getnotification        = "Getnotification"
    case deeletNotifiction      = "deeletNotifiction"
    case CompleteProfile        = "CompleteProfile"
    case CraeteContact          = "CraeteContact"
    case DeleteAccount          = "DeleteAccount"
    case Get_profile            = "Get_profile"
    case ProductLike_list       = "ProductLike_list"
    case FaQApi                 = "FaQApi"
    case logOut                 = "logOut"
    case barCodeDetail          = "BarCodeDetail"
}

enum DefaultKeys: String {
    case token
    case authKey
    case authToken
    case loginvalue
    case securitykey
    case email
    case password
    case userDetails
    case autoLogin
    case deviceToken
    case voipDeviceToken
    case loginDetls
    case Save
    case buisnessId
    case receiverId
    case filterdata
    case filterStore
    case fitlerBrand
    case defaultcardid
    case isArabicLang
    case isWalkthroughDisabled
}

enum ValidationCountsLimit: Int {
    case minimumPhoneNumber = 8
    case maximumPhoneNumber = 12
    case otpCount = 4
}

enum Services: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

enum Strings {
    static let uploads = "/uploads/"
    static let services = "Services:"
    
}

enum ImageNames {
    static let buttonOff = "BtnOff"
    static let buttonOn = "BtnOn"
}

enum Messages {
    static let locationEnableMessage = "Please enter location so that you can get service providers nearby you"
    static let emptyProviderList = "No requests yet!"
    static let emptylist = "No data found"
}

enum RegexMessages {
    static let invalidCountryCode = "Please select country code"
    static let emptyPhoneNumber = "Enter your phone number"
    static let emptyFirstName = "Please enter first name"
    static let emptyName = "Please enter name".localized()
    static let invalidFirstName = "Please enter valid name"
    static let emptyLastName = "Please enter last name"
    static let invalidLastName = "Please enter valid last name"
    static let emptyEmail = "Please enter email".localized()
    static let invalidEmail = "Please enter valid email"
    static let emptyAddress = "Please enter address"
    static let empltyHouseNumber = "Please enter house number"
    static let selectTerms = "Please accept our Terms & Conditions"
    static let emptyCardName = "Please enter card name"
    static let emptyCardNumber = "Please enter card number"
    static let emptyExpiryMonth = "Please enter expiry month"
    static let emptyExpiryYear = "Please enter expiry year"
    static let emptyCVC = "Please enter CVC number"
    static let invalidPhoneNumber = "Please enter valid phone number"
    static let emptyMessage = "Please enter message".localized()
    static let bookingSuccess = "Booking created successfully"
    static let invalidEmptyAddress = "Please enter address"
    static let invalidEmptyDate = "Please enter date"
    static let invalidEmptyTime = "Please enter time"
    static let invalidEmptyDescription = "Please enter description"
    static let invalidEmptyAudio = "Please add voice note"
    static let imagesCount = "Please upload atleast 1 image"
    static let videosCount = "Please upload atleast 1 videos"
    static let imageLimitExceeds = "Cannot add more than 9 images"
    static let videoLimitExceeds = "Cannot add more than 9 videos"
    static let emptytittle = "Please enter title".localized()
    static let emptyDescription = "Please enter description".localized()
    static let VerificationOTP = "Please enter static OTP 1111".localized()
}

enum dateFormat:String {
    case monthdayYear = "MM/dd/yyyy"
    case dayMonthYear = "dd/MM/yyyy"
    case yearMonthDay = "yyyy-MM-dd"
    case BackEndFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    case mon_dd_yyyy = "MMM dd, yyyy"
    case hh_mm_a_MM_dd_yy = "hh:mm a MM-dd-yy"
    case mon_dd_yyyy_hh_mm_a = "MMM dd, yyyy  hh:mm a"
    case hh_mm_a  = "HH:mm"
    case fulldate = "MM_dd_yy_HH:mm:ss"
}

enum AppStoryboard: String{
    case Main = "Main"
    case tabBar = "TabbarController"
    var instance: UIStoryboard{
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}

var rootVC: UIViewController?{
    get{
        return UIApplication.shared.windows.first?.rootViewController
    }
    set{
        UIApplication.shared.windows.first?.rootViewController = newValue
    }
}

//MARK: SHOW SWIFTY MESSAGE
func showSwiftyAlert(_ Title :String,_ body: String ,_ isSuccess : Bool){
    DispatchQueue.main.async {
        let warning = MessageView.viewFromNib(layout: .cardView)
        if isSuccess == true{
            warning.configureTheme(.success)
        }else{
            warning.configureTheme(.error)
        }
        warning.configureDropShadow()
        warning.configureContent(title: Title, body: body)
        warning.button?.isHidden = true
        // warning.iconImageView?.image = #imageLiteral(resourceName: "imgNavLogo")
        var warningConfig = SwiftMessages.defaultConfig
        warningConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        warningConfig.duration = .seconds(seconds: 1)
        SwiftMessages.show(config: warningConfig, view: warning)
    }
}

func SwiftyAlert(_ Title :String,_ body: String ,_ isSuccess : Bool){
    DispatchQueue.main.async {
        let warning = MessageView.viewFromNib(layout: .cardView)
        if isSuccess == true{
            warning.configureTheme(.success)
        }else{
            warning.configureTheme(.error)
        }
        warning.configureDropShadow()
        warning.configureContent(title: Title, body: body)
        warning.button?.isHidden = true
        // warning.iconImageView?.image = #imageLiteral(resourceName: "imgNavLogo")
        var warningConfig = SwiftMessages.defaultConfig
        warningConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        warningConfig.duration = .seconds(seconds: 2)
        SwiftMessages.show(config: warningConfig, view: warning)
    }
}
extension UICollectionView {
    func reloadData(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData()})
        {_ in completion() }
    }
    
    func setNoDataMessage(_ message: String,txtColor:UIColor) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = txtColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Poppins-Medium", size: 20)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
}

//MARK:- Extensions UITableView view
extension UITableView {
    func reloadData(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData()})
        {_ in completion() }
    }
    
    func setNoDataMessage(_ message: String,txtColor:UIColor) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = txtColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Poppins-Medium", size: 20)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    
    func newsetNoDataMessage(_ message: String,txtColor:UIColor,image:UIImage) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        let image = UIImageView(frame: CGRect(x: self.bounds.size.width / 2 - 80, y: self.bounds.size.height / 2 - 50 , width: 150, height: 150))
        image.image = UIImage(named: "1024")
        view.addSubview(image)
        let messageLabel = UILabel(frame: CGRect(x: 0, y: self.bounds.size.height / 2 + 80, width: self.bounds.size.width, height: 50))
        messageLabel.text = message
        messageLabel.textColor = txtColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Roboto-Regular", size: 20)
        view.addSubview(messageLabel)
        self.backgroundView = view
        
    }
}
