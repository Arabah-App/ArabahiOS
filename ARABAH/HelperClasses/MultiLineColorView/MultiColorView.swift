//
//  MultiColorView.swift
//  ARABAH
//
//  Created by cql71 on 04/03/25.
//

import UIKit

class MultiColorView: UIView {
        
    var valueRanges: [(start: CGFloat, end: CGFloat, color: UIColor)] = []
    var minValue: CGFloat = 0
    var maxValue: CGFloat = 100
    
    // Custom initializer to set dynamic values
    init(frame: CGRect, minValue: CGFloat, maxValue: CGFloat, valueRanges: [(CGFloat, CGFloat, UIColor)]) {
        super.init(frame: frame)
        self.minValue = minValue
        self.maxValue = maxValue
        self.valueRanges = valueRanges
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !valueRanges.isEmpty else { return }
        let totalWidth = rect.width
        for range in valueRanges {
            let startX = (range.start - minValue) / (maxValue - minValue) * totalWidth
            let width = (range.end - range.start) / (maxValue - minValue) * totalWidth
            context.setFillColor(range.color.cgColor)
            context.fill(CGRect(x: startX, y: 0, width: width, height: rect.height))
        }
    }
}


