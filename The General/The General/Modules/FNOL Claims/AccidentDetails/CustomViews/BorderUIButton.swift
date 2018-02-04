//
//  BorderUIButton.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

@IBDesignable
class BorderUIButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = isSelected ? 4 : 1
            self.layer.borderColor = isSelected ? UIColor.tgGreen.cgColor : UIColor.tgGray.cgColor
            self.layer.cornerRadius = isSelected ? 2 : 1

        }
    }
    
	override var isEnabled: Bool {
		didSet {
			if backgroundColor != .clear {
				backgroundColor = isEnabled ? .tgGreen : .tgGray
			} else {
				setTitleColor(isEnabled ? .tgGreen : .tgGray, for: .normal)
			}
			self.layer.borderColor = (isEnabled ? UIColor.tgGreen.cgColor : UIColor.tgGray.cgColor)
		}
	}
	
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
