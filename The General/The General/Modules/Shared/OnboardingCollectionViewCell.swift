//
//  OnboardingCollectionViewCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var contentLabel: UILabel!
	
	var cellType: OnboardingCardType = .unknown
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.layer.masksToBounds = true
		self.layer.cornerRadius = 5;
		self.layer.shadowOffset =  CGSize(width: -15, height: 20)
		self.layer.shadowRadius = 20;
		self.layer.shadowOpacity = 0.3;
		self.clipsToBounds = false
	}
	
	static var nib: UINib {
		return UINib(nibName: identifier, bundle: nil)
	}
	
	static var identifier: String {
		return String(describing: self)
	}

}
