//
//  APIRequest.swift
//  AffroppleApp
//
//  Created by apple on 11/09/19.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation
import MBProgressHUD
import SwiftMessageBar


struct WebService {
    static let boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
    static func service<Model: Codable>(_ api: API, urlAppendId: Any? = nil, param: Any? = nil, service: Services = .post ,showHud: Bool = true, headerAppendId: String? = nil, response:@escaping (Model,Data,Any) -> Void){
        if Reachability.isConnectedToNetwork(){
            //SET URL
            var fullUrlString = baseURL + api.rawValue
            if let idApend = urlAppendId{
                fullUrlString = baseURL + api.rawValue + "/\(idApend)"
            }
            //METHOD GET
            if service == .get{
                if let parm = param{
                    if parm is String{
                        fullUrlString.append("?")
                        fullUrlString += (parm as! String)
                    }else if parm is Dictionary<String, Any>{
                        fullUrlString += self.getString(from: parm as! Dictionary<String, Any>)
                    }else{
                        assertionFailure("Parameter must be Dictionary or String.")
                    }
                }
            }
            print(fullUrlString)
            guard let encodedString = fullUrlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {return}
            var request = URLRequest(url: URL(string: encodedString)!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 2000)
            request.httpMethod = service.rawValue
            
            //SET AUTH KET

            if let authKey = Store.authToken{
                print("AUTH KEY IS:- \(authKey)")
                if Store.authToken != "" {
                    request.addValue("Bearer " + authKey, forHTTPHeaderField: "Authorization")
                }
                
            }

            request.addValue(Store.isArabicLang ? "ar" : "en", forHTTPHeaderField: "language_type")
            request.addValue(SECRET_KEY, forHTTPHeaderField: "secret_key")
            request.addValue(PUBLISH_KEY, forHTTPHeaderField: "publish_key")
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            //METHOD DETELE
            if service == .delete {
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                if let param = param{
                    if param is String{
                        let postData = NSMutableData(data: (param as! String).data(using: String.Encoding.utf8)!)
                        request.httpBody = postData as Data
                    }else if param is Dictionary<String, Any>{
                        var parm = self.getString(from: param as! Dictionary<String, Any>)
                        //print(parm)
                        parm.removeFirst()
                        let postData = NSMutableData(data: parm.data(using: String.Encoding.utf8)!)
                        request.httpBody = postData as Data
                    }
                }
            }
            
            //METHOD POST/PUT
            if service == .post || service == .put{
                if let parameter = param{
                    if parameter is String{
                        request.httpBody = (parameter as! String).data(using: .utf8)
                    }else if parameter is Dictionary<String, Any>{
                        var body = Data()
                        for (key, Value) in parameter as! Dictionary<String, Any>{
                            print(key,Value)
                            if let imageInfo = Value as? ImageStructInfo{
                                body.append("--\(boundary)\r\n")
                                body.append("Content-Disposition: form-data; name=\"\(imageInfo.key)\"; filename=\"\(imageInfo.fileName)\"\r\n")
                                body.append("Content-Type: \(imageInfo.type)\r\n\r\n")
                                body.append(imageInfo.data)
                                body.append("\r\n")
                                
                            }else if let images = Value as? [ImageStructInfo]{
                                for value in images{
                                    body.append("--\(boundary)\r\n")
                                    body.append("Content-Disposition: form-data; name=\"\(value.key)\"; filename=\"\(value.fileName)\"\r\n")
                                    body.append("Content-Type: \(value.type)\r\n\r\n")
                                    body.append(value.data)
                                    body.append("\r\n")
                                }
                            }else{
                                body.append("--\(boundary)\r\n")
                                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                                body.append("\(Value)\r\n")
                            }
                        }
                        body.append("--\(boundary)--\r\n")
                        request.httpBody = body
                    }else{
                        assertionFailure("Parameter must be Dictionary or String.")
                    }
                }
            }
            let sessionConfiguration = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfiguration)
            //LOADER SHOW
            if showHud{
                applicationDelegate.showLoader()
            }
            session.dataTask(with: request) { (data, jsonResponse, error) in
                //LOADER HIDE
                if showHud{
                    
                    DispatchQueue.main.async {
                        applicationDelegate.hIdeLoader()
                    }
                }
                
                if error != nil{
                    WebService.showAlert(error!.localizedDescription)
                }else{
                    if let jsonData = data{
                        do{
                            let jsonSer = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [String: Any]
                            print(jsonSer)
                            let codeInt = jsonSer["code"] as? Int ?? 0
                            let code = "\(codeInt)"
                            
                            // ERRORE CODE UNAUTHORIZED
                            if code == "401"{
                                DispatchQueue.main.async {
                                    Store.filterdata = nil
                                    Store.fitlerBrand = nil
                                    Store.filterStore = nil
                                    Store.userDetails = nil
                                    Store.authToken = nil
                                    Store.autoLogin = false
                                    Store.isfromsecure = ""
                                    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                                    let controller = mainStoryBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                    let navigationController = UINavigationController(rootViewController: controller)
                                    navigationController.isNavigationBarHidden = true
                                    controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                                    UIApplication.shared.windows.first?.rootViewController = navigationController
                                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                                }
                                
                            }else if code == "400"{
                                if let errorMessage = jsonSer["msg"] as? String{
                                    CommonUtilities.shared.showAlert(message: errorMessage, isSuccess: .error)
                                }else if let message = jsonSer["message"] as? String{
                                    CommonUtilities.shared.showAlert(message: message, isSuccess: .error)
                                }
                                // ERRORE CODE FORBIDDEN
                            }else if code == "403"{
                                if let errorMessage = jsonSer["message"] as? String{
                                    CommonUtilities.shared.showAlert(message: errorMessage, isSuccess: .error)
                                }else if let message = jsonSer["message"] as? String{
                                    CommonUtilities.shared.showAlert(message: message, isSuccess: .success)
                                }
                                DispatchQueue.main.async {
                                    if UIApplication.shared.isRegisteredForRemoteNotifications{
                                        UIApplication.shared.unregisterForRemoteNotifications()
                                        UIApplication.shared.registerForRemoteNotifications()
                                    }
                                    //applicationDelegate.setUpLogin()
                                }
                                // ERRORE CODE UNSUCCES
                            }else if code != "200"{
                                DispatchQueue.main.async {
                                    if let errorMessage = jsonSer["message"] as? String{
                                        CommonUtilities.shared.showAlert(message: errorMessage, isSuccess: .error)
                                    }else if let message = jsonSer["message"] as? String{
                                        CommonUtilities.shared.showAlert(message: message, isSuccess: .success)
                                    }
                                }
                            }else{
                                let decoder = JSONDecoder()
                                let model = try decoder.decode(Model.self, from: jsonData)
                                DispatchQueue.main.async {
                                    response(model,jsonData,jsonSer)
                                }
                            }
                        }catch let err{
                            print(err)
                            WebService.showAlert(err.localizedDescription)
                        }
                    }
                }
            }.resume()
        }else{
            self.showAlert(noInternetConnection)
        }
    }
    private static func showAlert(_ message: String){
        DispatchQueue.main.async {
           showAlert(message)
        }
    }
    private static func getString(from dict: Dictionary<String,Any>) -> String{
        var stringDict = String()
        stringDict.append("?")
        for (key, value) in dict{
            let param = key + "=" + "\(value)"
            stringDict.append(param)
            stringDict.append("&")
        }
        stringDict.removeLast()
        return stringDict
    }
}
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8){
            append(data)
        }
    }
}
extension UIImage{
    func toData() -> Data{
        return self.jpegData(compressionQuality: 0.2)!

    }
    func isEqualToImage(image: UIImage) -> Bool
    {
        let data1: Data = self.pngData()!
        let data2: Data = image.pngData()!
        return data1 == data2
    }
}

struct ImageStructInfo {
    var fileName: String
    var type: String
    var data: Data
    var key:String
}
