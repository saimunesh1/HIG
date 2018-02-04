//
//  PaymentAmountBaseCollectionViewCell.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/7/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PaymentAmountBaseCollectionViewCell: UICollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.tgGray.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.borderColor = (self.isSelected) ? UIColor.tgGreen.cgColor : UIColor.tgGray.cgColor
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 110, height: 110)
    }
    
    override var isSelected: Bool {
        set {
            super.isSelected = newValue
            self.layer.borderColor = (newValue) ? UIColor.tgGreen.cgColor : UIColor.tgGray.cgColor
        }
        get {
            return super.isSelected
        }
    }
}
