//
//  CustomSwitch.swift
//  IDKanswers
//
//  Created by apple on 30/03/23.
//

import Foundation
import UIKit
@IBDesignable

class UISwitchCustom: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}
