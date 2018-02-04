//
//  BadgeView.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 12/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class BadgeView: UIView {
    
    @IBOutlet fileprivate weak var badgeImageView: UIImageView!
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: badgeImageView.frame.origin.x, y: 0))
        path.addArc(center: badgeImageView.center, radius: badgeImageView.frame.height / 2, startAngle: 290, endAngle: 35, clockwise: true)
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        layer.shadowPath = path
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = UIColor.tgLightGreen
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 7
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: -3, height: 3)
    }
}

class RoundedImageView: UIImageView {
    
    // **** Badge desired traits ****
    @IBInspectable var borderColor: UIColor = UIColor.tgHeaderGreen
    @IBInspectable var borderWidth: CGFloat = 2
    //
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    fileprivate func setup() {
        self.layer.masksToBounds = true
        self.layer.borderColor = self.borderColor.cgColor
        self.layer.borderWidth = self.borderWidth
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
