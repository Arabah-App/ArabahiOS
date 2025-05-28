//
//  AppDelegate.swift
//  ARABAH
//
//  Created by cqlios on 18/10/24.
//

import UIKit
import MBProgressHUD
import IQKeyboardManagerSwift
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var deviceToken:String = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.isEnabled = true
        GMSPlacesClient.provideAPIKey(googlePlacesApiKey)
        registerForPushNotifications()
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate{
    func showLoader(){
        if let vc = UIApplication.shared.keyWindow{
            MBProgressHUD.showAdded(to: vc, animated: true)
        }
    }
    func hIdeLoader(){
        if let vc = UIApplication.shared.keyWindow{
            MBProgressHUD.hide(for: vc, animated: true)
        }
    }
    //MARK: Custom Methods
    class var shared:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if granted {
                print("Permission granted: \(granted)")
                // 1. Check if permission granted
                guard granted else { return }
                // 2. Attempt registration for remote notifications on the main thread
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Permission granted: \(granted)")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        print("Device Token: \(token)")
        Store.deviceToken = token
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
        self.deviceToken = "simulator/error"
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("**********************")
        print(userInfo)
        let userInfos = userInfo["body"] as?  [String:Any]
        let Staustype = userInfos?["notification_type"] as? Int
        completionHandler([.sound,.banner,.badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let dict = response.notification.request.content.userInfo
        let apnsData = dict["data"] as? [String: Any]
        let productID = apnsData?["sender_id"] as? String
        let statusType = apnsData?["notification_type"] as? Int

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if statusType == 1 {
            //MARK: - SEND QUOTE
            let vc = storyboard.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
            vc.prodcutid = productID ?? ""
            if let topVC = UIApplication.shared.windows.first?.rootViewController {
                if let navController = topVC as? UINavigationController {
                    navController.pushViewController(vc, animated: true)
                } else if let navController = topVC.navigationController {
                    navController.pushViewController(vc, animated: true)
                } else {
                    topVC.present(vc, animated: true, completion: nil)
                }
            }
        }
        completionHandler()
    }

}
