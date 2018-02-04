//
//  RoundView.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 11/20/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class RoundView: UIView {
    @IBInspectable
    
    var radius: CGFloat = CGFloat(0)
    var round: Bool = false
    
    override func awakeFromNib() {
        self.layer.cornerRadius = self.radius
    }
    
    override func layoutSubviews() {
        if self.round {
            let width = self.bounds.size.width;
            let radius = CGFloat( width * 0.5 );
            self.layer.cornerRadius = radius;
        }
    }
    
}
