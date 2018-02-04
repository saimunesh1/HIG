//
//  PolicyDateCompletion.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PolicyDateCompletionLineView: PolicyDateStatusView {
    
    private struct Dimensions {
        static let paddingXY: CGFloat = 10
        static let circleRadMultiplier: CGFloat = 0.01
    }
    
    override func setupViews() {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawEmptyTrack()
        drawFilledTrack()
        drawLeftCircle()
        drawRightCircle()
    }
    
    override func drawEmptyTrack() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: Dimensions.paddingXY, y: bounds.size.height / 2.0))
        path.addLine(to: CGPoint(x: bounds.size.width - Dimensions.paddingXY, y: bounds.size.height / 2.0))
        UIColor.tgGray.setStroke()
        
        path.lineWidth = 2.0
        path.stroke()
    }
    
    override func drawFilledTrack() {
        var policyProgress = 0.0
        if let policyEffectiveDate = dashboardInfo?.policyEffectiveDate, let policyEndDate = dashboardInfo?.policyEndDate {
            let now = Date()
            let totalTimeInterval = policyEndDate.timeIntervalSince(policyEffectiveDate)
            let currentTimeInterval = now.timeIntervalSince(policyEffectiveDate)
            policyProgress = min(currentTimeInterval / totalTimeInterval, 1.0)
        }
        
        let lengthProgress = CGFloat(policyProgress) * (bounds.size.width - Dimensions.paddingXY)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: Dimensions.paddingXY, y: bounds.size.height / 2.0))
        path.addLine(to: CGPoint(x: lengthProgress, y: bounds.size.height / 2.0))

        UIColor.tgGreen.setStroke()
        
        path.lineWidth = 2.0
        path.stroke()
    }
    
    override func drawLeftCircle() {
        let centerY = bounds.size.height / 2.0
        let rad = bounds.size.width * Dimensions.circleRadMultiplier
        let r = CGRect(x: Dimensions.paddingXY - rad / 2, y: centerY - rad, width: rad * 2.0, height: rad * 2.0)
        let path = UIBezierPath(ovalIn: r)
        UIColor.tgGreen.setFill()
        path.fill()
    }
    
    override func drawRightCircle() {
        let centerY = bounds.size.height / 2.0
        let rad = bounds.size.width * Dimensions.circleRadMultiplier
        let r = CGRect(x: bounds.size.width - Dimensions.paddingXY - rad / 2, y: centerY - rad, width: rad * 2.0, height: rad * 2.0)
        let path = UIBezierPath(ovalIn: r)
        
        if let dashboardInfo = dashboardInfo, dashboardInfo.isExpiredPolicy {
            UIColor.tgRed.setFill()
            path.fill()
        } else {
            UIColor.white.setFill()
            UIColor.tgGray.setStroke()
            path.lineWidth = 2.0
            path.fill()
            path.stroke()
        }
    }
}
