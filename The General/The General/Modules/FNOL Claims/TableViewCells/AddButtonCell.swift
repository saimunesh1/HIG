//
//  AddButtonCell.swift
//  The General
//
//  Created by Trevor Alyn on 10/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AddButtonCell: BaseTableViewCell {

	@IBOutlet weak var circleImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	
	var item: Field? {
		didSet {
			guard let value = item else {
				return
			}
			self.titleLabel.text = value.label
		}
	}
	
	override func awakeFromNib() {
        super.awakeFromNib()
		circleImageView.tintColor = .tgGreen
		titleLabel.textColor = .tgGreen
    }

}
