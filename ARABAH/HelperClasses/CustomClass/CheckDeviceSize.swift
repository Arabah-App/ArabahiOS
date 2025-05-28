//
//  CheckDeviceSize.swift
//  Nexever
//
//  Created by apple on 29/05/21.
//

import Foundation
import UIKit

struct ScreenSize
{
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)
    static let maxWH = max(ScreenSize.width, ScreenSize.height)
}

struct DeviceType
{
    static let iPhone4orLess = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxWH < 568.0
    static let iPhone5orSE   = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxWH == 568.0
    static let iPhone678     = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxWH == 667.0
    static let iPhone678p    = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxWH == 736.0
    static let iPhoneX       = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxWH == 812.0
    static let iPhoneXRMax   = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxWH == 896.0
    static var hasNotch: Bool
    {
        return iPhoneX || iPhoneXRMax
    }
    static var isIPhone: Bool
    {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var isIPad: Bool
    {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

