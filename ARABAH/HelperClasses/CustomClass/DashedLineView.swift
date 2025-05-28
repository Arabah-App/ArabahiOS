//
//  DashedLineView.swift
//  PAS transport
//
//  Created by cqlpc on 16/10/24.
//

import UIKit

class DashedLineView: UIView {
    
    private let borderLayer = CAShapeLayer()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderLayer.strokeColor = UIColor.black.cgColor
        borderLayer.lineDashPattern = [6,7]
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        
        layer.addSublayer(borderLayer)
    }
    
    override func draw(_ rect: CGRect) {
        borderLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: 14).cgPath
    }
}
