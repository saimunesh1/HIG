//
//  BorderStackView.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/23/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

@IBDesignable
class BorderStackView: UIStackView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}