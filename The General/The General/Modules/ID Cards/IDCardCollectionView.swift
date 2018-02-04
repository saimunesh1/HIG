//
//  IDCardCollectionView.swift
//  The General
//
//  Created by Hopkinson, Todd (US - Denver) on 1/8/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class IDCardCollectionView: UICollectionView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        self.layer.shadowOffset =  CGSize(width: -15, height: 20)
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.1
        self.clipsToBounds = false
    }
}
