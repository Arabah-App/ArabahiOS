//
//  CommonUtilities.swift
//  WeedFuzz
//
//  Created by apple on 14/12/21.
//

import Foundation
import SwiftMessages

class CommonUtilities
{
    static let shared = CommonUtilities()
    func showAlert( Title :String = "", message: String , isSuccess : Theme,  duration: TimeInterval = 3.5){
        DispatchQueue.main.async {
            SwiftMessages.hideAll()
            let warning = MessageView.viewFromNib(layout: .cardView)
            warning.configureTheme(isSuccess)
            warning.backgroundView.backgroundColor = (isSuccess == .success) ? #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1) : .red
            warning.configureDropShadow()
            warning.configureContent(title: Title, body: message)
            warning.button?.isHidden = true
            var warningConfig = SwiftMessages.defaultConfig
            warningConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
            warningConfig.duration = .seconds(seconds: duration)
            SwiftMessages.show(config: warningConfig, view: warning)
        }
    }
    
    func showAlert(message :String){
        DispatchQueue.main.async
        {
            let alert = UIAlertController(title:"", message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                DispatchQueue.main.async {
                    alert.dismiss(animated: true, completion: nil)
                }
            })

            alert.addAction(ok)
            DispatchQueue.main.async {
                if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first{
                    DispatchQueue.main.async {
                        window.rootViewController!.present(alert, animated: true)
                    }
                }
            }
        }
    }
}
