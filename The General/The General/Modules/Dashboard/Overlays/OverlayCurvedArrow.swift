//
//  OverlayCurvedArrow.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/27/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class OverlayCurvedArrow: UIView {
    var arrowBoundingRect: CGRect = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
     
        let width = arrowBoundingRect.size.width
        let height = arrowBoundingRect.size.height
        let left = arrowBoundingRect.origin.x
        let top = arrowBoundingRect.origin.y
        let right = left + width
        let bottom = top + height
        
        let bezierPath = UIBezierPath()

        // NOTE: the bezier constants below come from PaintCode and shouldn't be adjusted by hand
        // arrow tail
        bezierPath.move(to: CGPoint(x: left, y: bottom))
        bezierPath.addCurve(to: CGPoint(x: left, y: top + height * 0.37), controlPoint1: CGPoint(x: left + width * 0.0204, y: top + height * 0.945), controlPoint2: CGPoint(x: left + width * -0.1108, y: top + height * 0.5211))
        bezierPath.addCurve(to: CGPoint(x: right, y: top), controlPoint1: CGPoint(x: left + width * 0.1883, y: top + height * 0.0863), controlPoint2: CGPoint(x: left + width * 0.985, y: top))
        
        // top head arrow
        bezierPath.addLine(to: CGPoint(x: right - 20.0, y: top - 15.0))
        
        // bottom head arrow
        bezierPath.move(to: CGPoint(x: right, y: top))
        bezierPath.addLine(to: CGPoint(x: right - 20.0, y: top + 20.0))

        UIColor.white.setStroke()
        bezierPath.lineWidth = 4.0
        bezierPath.lineCapStyle = .round
        bezierPath.lineJoinStyle = .round

        bezierPath.stroke()
    }
}
