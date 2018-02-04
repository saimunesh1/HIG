//
//  IDCardCollectionViewCell.swift
//  The General
//
//  Created by Hopkinson, Todd (US - Denver) on 1/8/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class IDCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var makeModelYearLabel: UILabel!
    @IBOutlet weak var vinLabel: UILabel!
    @IBOutlet weak var policyNumberLabel: UILabel!
    @IBOutlet weak var effectiveRangeLabel: UILabel!
    @IBOutlet weak var policyNumberDetailLabel: UILabel!
    @IBOutlet weak var effectiveDateRangeDetailLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var policyNotValidLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        self.layer.shadowOffset =  CGSize(width: -15, height: 20)
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.3
        self.clipsToBounds = false
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.cornerRadius = 14
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
