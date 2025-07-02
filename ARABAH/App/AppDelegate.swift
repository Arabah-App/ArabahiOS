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
import FirebaseCrashlytics
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    /// Stores the device token string for push notifications
    var deviceToken: String = ""
    
    /// Called when the app has finished launching.
    /// Performs initial setup such as enabling keyboard manager, setting Google Places API key, and registering for push notifications.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.isEnabled = true  // Enable IQKeyboardManager for automatic keyboard handling
        IQKeyboardManager.shared.resignOnTouchOutside = true
        GMSPlacesClient.provideAPIKey(googlePlacesApiKey) // Setup Google Places API key
        registerForPushNotifications() // Request push notification permissions
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    /// Called when a new scene session is being created.
    /// Returns a configuration object to create the new scene with.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Using default configuration here
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /// Called when the user discards a scene session.
    /// Use this to release resources specific to discarded scenes.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // No custom behavior implemented here
    }
}

// MARK: - Loader Helper Methods

extension AppDelegate {
    /// Shared singleton instance of AppDelegate
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

// MARK: - Push Notification Handling

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// Request user authorization for push notifications and register for remote notifications if granted
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Permission granted: \(granted)")
                // Register for remote notifications on main thread
                DispatchQueue.main.async { [weak self] in
                    guard let _ = self else { return }
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Permission denied: \(granted)")
            }
        }
    }
    
    /// Called when the app successfully registers for remote notifications.
    /// Converts device token data to string and stores it for later use.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        Store.deviceToken = token
    }
    
    /// Called when the app fails to register for remote notifications.
    /// Logs the error and sets a fallback device token.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error)")
        self.deviceToken = "simulator/error"
    }
    
    /// Called when a notification is received while the app is in the foreground.
    /// Determines how the notification should be presented.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("**********************")
        print(userInfo)
        completionHandler([.sound, .banner, .badge])  // Show alert with sound and badge even in foreground
    }
    
    /// Called when the user taps on a notification to open the app.
    /// Handles navigation based on notification payload.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let dict = response.notification.request.content.userInfo
        let apnsData = dict["data"] as? [String: Any]
        let productID = apnsData?["sender_id"] as? String
        let statusType = apnsData?["notification_type"] as? Int
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if statusType == 1 {
            // MARK: - Navigate to SubCatDetailVC on "SEND QUOTE" notification type
            let vc = storyboard.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
            vc.prodcutid = productID ?? ""
            
            // Get topmost view controller and push or present the target VC accordingly
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

// MARK: - Helper to get the top-most ViewController in the app's view hierarchy

extension UIApplication {
    /// Returns the top-most view controller from the given controller (or rootViewController by default)
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension UIApplication {
    /// Changes the root view controller with optional animation
    /// - Parameters:
    ///   - controller: The new root view controller
    ///   - animated: Whether to animate the transition
    ///   - duration: Animation duration (default: 0.3)
    ///   - options: Animation options (default: .transitionCrossDissolve)
    ///   - completion: Optional completion handler
    static func setRootViewController(
        _ controller: UIViewController,
        animated: Bool = true,
        duration: TimeInterval = 0.3,
        options: UIView.AnimationOptions = .transitionCrossDissolve,
        completion: (() -> Void)? = nil
    ) {
        guard let window = shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        if animated {
            UIView.transition(with: window, duration: duration, options: options, animations: {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = controller
                UIView.setAnimationsEnabled(oldState)
            }, completion: { _ in
                completion?()
            })
        } else {
            window.rootViewController = controller
            completion?()
        }
    }
}
