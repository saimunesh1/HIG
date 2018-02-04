//
//  CustomGradientView.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

@IBDesignable class CustomGradientView: UIView {
    @IBInspectable var firstColor: UIColor = UIColor.gray
    @IBInspectable var secondColor: UIColor = UIColor.white
    
    class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [firstColor.cgColor, secondColor.cgColor]
    }
}
