//
//  Store.swift
//  Unavail
//
//  Created by Pallvi on 23/08/21.
//

import Foundation

class Store {
   
   class var authToken: String?
    {
        set {
            Store.saveValue(newValue, .authToken)
        }get{
            return Store.getValue(.authToken) as? String
        }
    }
    class var receiverId: Int?
    {
        set{
            Store.saveValue(newValue, .receiverId)
        }get{
            return Store.getValue(.receiverId) as? Int ?? 0
        }
    }
    class var isfromsecure: String?{
        set {
            Store.saveValue(newValue, .loginvalue)
        }get{
            return Store.getValue(.loginvalue) as? String
        }
    }
    class var isArabicLang: Bool{
        set{
            Store.saveValue(newValue, .isArabicLang)
        }get{
            return Store.getValue(.isArabicLang) as? Bool ?? false
        }
    }
    class var buissnessID: Int?{
        set {
            Store.saveValue(newValue, .buisnessId)
        }get{
            return Store.getValue(.buisnessId) as? Int
        }
    }
    class var filterdata: [String]?{
        set {
            Store.saveValue(newValue, .filterdata)
        }get{
            return Store.getValue(.filterdata) as?  [String]
        }
    }
    
    class var filterStore: [String]?{
        set {
            Store.saveValue(newValue, .filterStore)
        }get{
            return Store.getValue(.filterStore) as?  [String]
        }
    }
    
    class var fitlerBrand: [String]?{
        set {
            Store.saveValue(newValue, .fitlerBrand)
        }get{
            return Store.getValue(.fitlerBrand) as?  [String]
        }
    }
    
    class var securitykey: String?
     {
         set {
             Store.saveValue(newValue, .securitykey)
         }get{
             return Store.getValue(.securitykey) as? String
         }
     }
    
    class var deviceToken: String?
    {
        set{
            Store.saveValue(newValue, .deviceToken)
        }get{
            return Store.getValue(.deviceToken) as? String
        }
    }
    
    class var  VoipdeviceToken: String?
    {
        set{
            Store.saveValue(newValue, .voipDeviceToken)
        }get{
            return Store.getValue(.voipDeviceToken) as? String
        }
    }
    
    class var defaultcardid : Int?
    {
        set{
            Store.saveValue(newValue, .defaultcardid)
        }get{
            return Store.getValue(.defaultcardid) as? Int
            
        }
    }
    
    class var userDetails: LoginModal?
    {
        set{
            Store.saveUserDetails(newValue, .userDetails)
        }get{
            return Store.getUserDetails(.userDetails)
        }
    }
//    
//    class var professionaluserDetails: ProfessionalSignUpModel?
//    {
//        set{
//            Store.saveUserDetails(newValue, .userDetails)
//        }get{
//            return Store.getUserDetails(.userDetails)
//        }
//    }
//    
    class var userLoginDetail: LoginModal?
    {
        set{
            Store.saveUserDetails(newValue, .loginDetls)
       //     Store.authKey = newValue?.body?.token ?? ""
        }get{
            return Store.getUserDetails(.loginDetls)
        }
    }
    
    class var autoLogin: Bool
    {
        set{
            Store.saveValue(newValue, .autoLogin)
        }
        get{
            return Store.getValue(.autoLogin) as? Bool ?? false
        }
    }
    
    
    class var isWalkthroughDisabled: Bool
    {
        set{
            Store.saveValue(newValue, .isWalkthroughDisabled)
        }
        get{
            return Store.getValue(.isWalkthroughDisabled) as? Bool ?? false
        }
    }
     
    static var remove: DefaultKeys!{
        didSet{
            Store.removeKey(remove)
        }
    }
    //MARK:-  Private Functions
    private class func removeKey(_ key: DefaultKeys)
    {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        if key == .userDetails{
            UserDefaults.standard.removeObject(forKey: DefaultKeys.authKey.rawValue)
        }
        UserDefaults.standard.synchronize()
    }
    
    private class func saveValue(_ value: Any? ,_ key:DefaultKeys)
    {
       
        var data: Data?
        if let value = value
        {
          //  data = NSKeyedArchiver.archivedData(withRootObject: value)
            data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
        }
        UserDefaults.standard.set(data, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    private class func saveUserDetails<T: Codable>(_ value: T?, _ key: DefaultKeys)
    {
        var data: Data?
        
        if let value = value
        {
            data = try? PropertyListEncoder().encode(value)
        }
        
        Store.saveValue(data, key)
    }
    
    private class func getUserDetails<T: Codable>(_ key: DefaultKeys) -> T? {
        if let data = self.getValue(key) as? Data{
            let loginModel = try? PropertyListDecoder().decode(T.self, from: data)
            return loginModel
        }
        return nil
    }
    
    private class func getValue(_ key: DefaultKeys) -> Any
    {
        if let data = UserDefaults.standard.value(forKey: key.rawValue) as? Data{
            if let value = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            {
                return value
            }
            else{
                return ""
            }
        }else{
            return ""
        }
    }
}
