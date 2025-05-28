//
//  WithoutAuthVC.swift
//  ARABAH
//
//  Created by cql71 on 21/01/25.
//

import UIKit

class WithoutAuthVC: UIViewController {
    
    @IBOutlet weak var skipSignInBtn: UIButton!
    @IBOutlet weak var viewMain: UIView!
    var isMoveToHome: Bool = false
    var callback : (()->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        skipSignInBtn.setLocalizedTitleButton(key: "Skip Sign In")
        viewMain.layer.cornerRadius = 12
        viewMain.layer.shadowColor = UIColor.black.cgColor
        viewMain.layer.shadowOpacity = 0.3
        viewMain.layer.shadowOffset = CGSize(width: 5, height: 5)
        viewMain.layer.shadowRadius = 10
    }
    
    @IBAction func btnSignIn(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.callback?()
        }
    }
    @IBAction func btnSkip(_ sender: UIButton) {
        if isMoveToHome == true {
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
        } else {
            self.dismiss(animated: true)
        }
        
        
//        let alert = UIAlertController(title: "Sign In Required".localized(),
//                                      message: "You need to sign in to access this feature.".localized(),
//                                      preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Sign In".localized(), style: .default, handler: { _ in
//            self.navigateToSignIn()
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
//        self.present(alert, animated: true, completion: nil)
    }

    func navigateToSignIn() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = mainStoryBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
