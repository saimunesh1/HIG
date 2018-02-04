//
//  PolicyDateStatusView.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PolicyDateStatusView: UIView {
    
    struct Dimension {
        static let percentGeneralRadius: CGFloat = 0.31
        static let percentGeneralBackgroundRadius: CGFloat = 0.32
        static let percentTrackRadius: CGFloat = 0.44
        static let percentSmallDotRadius: CGFloat = 0.06
    }
    
    var dashboardInfo: DashboardResponse? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func setupViews() {
        let generalImage = UIImage(named: "policy-general")
        generalImageView = UIImageView(image: generalImage)
        generalImageView?.translatesAutoresizingMaskIntoConstraints = false

        if let generalImageView = generalImageView {
            addSubview(generalImageView)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let generalImageView = generalImageView {
            let width = bounds.size.width
            let imageWidth = width * (Dimension.percentGeneralBackgroundRadius * 2.0)

            generalImageView.layer.masksToBounds = true
            generalImageView.layer.cornerRadius = generalImageView.bounds.size.width / 2.0

            generalImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            generalImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            generalImageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
            generalImageView.heightAnchor.constraint(equalToConstant: imageWidth).isActive = true
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawEmptyTrack()
        drawFilledTrack()
        drawLeftCircle()
        drawCenterCircle()
        drawRightCircle()
    }
    
    func drawEmptyTrack() {
        let c = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        let rad = bounds.size.width * Dimension.percentTrackRadius
        let path = UIBezierPath(arcCenter: c, radius: rad, startAngle: 0.0, endAngle: .pi, clockwise: true)

        UIColor.tgGray.setStroke()

        path.lineWidth = 2.0
        path.stroke()
    }

    func drawFilledTrack() {
        let c = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        let rad = bounds.size.width * Dimension.percentTrackRadius
        var policyProgress = 0.0
        
        if let policyEffectiveDate = dashboardInfo?.policyEffectiveDate, let policyEndDate = dashboardInfo?.policyEndDate {
            let now = Date()
            let totalTimeInterval = policyEndDate.timeIntervalSince(policyEffectiveDate)
            let currentTimeInterval = now.timeIntervalSince(policyEffectiveDate)

            policyProgress = min(currentTimeInterval / totalTimeInterval, 1.0)
        }
        
        let angleProgress = CGFloat((1.0 - policyProgress) * .pi)
        let path = UIBezierPath(arcCenter: c, radius: rad, startAngle: .pi, endAngle: angleProgress, clockwise: false)

        UIColor.tgGreen.setStroke()

        path.lineWidth = 2.0
        path.stroke()
    }

    func drawLeftCircle() {
        let center = bounds.size.width / 2.0
        let rad = bounds.size.width * Dimension.percentSmallDotRadius
        let r = CGRect(x: 0.0, y: center - rad, width: rad * 2.0, height: rad * 2.0)
        let path = UIBezierPath(ovalIn: r)
        
        UIColor.tgGreen.setFill()
        
        path.fill()
    }

    func drawCenterCircle() {
        let center = bounds.size.width / 2.0
        let rad = bounds.size.width * Dimension.percentGeneralBackgroundRadius
        let r = CGRect(x: center - rad, y: center - rad, width: rad * 2.0, height: rad * 2.0)
        let path = UIBezierPath(ovalIn: r)
        
        UIColor.tgGray.setFill()

        path.fill()
    }

    func drawRightCircle() {
        let center = bounds.size.width / 2.0
        let rad = bounds.size.width * Dimension.percentSmallDotRadius
        let r = CGRect(x: bounds.size.width - rad * 2.0, y: center - rad, width: rad * 2.0, height: rad * 2.0)
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

    
    // MARK: - Private
    private var generalImageView: UIImageView?    
}
