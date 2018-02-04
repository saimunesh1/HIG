//
//  ClaimsInfoCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/16/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsInfoCell: BaseTableViewCell {

	@IBOutlet weak var propertyLabel: UILabel!
	@IBOutlet weak var valueLabel: UILabel!
	
	public var isInteractive = false {
		didSet {
			valueLabel.textColor = isInteractive ? .tgGreen : .tgTextFontColor
			valueLabel.font = isInteractive ? UIFont.boldTitle : UIFont.largeText
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		valueLabel.textColor = .tgTextFontColor
	}
	
	override func prepareForReuse() {
		isInteractive = false
	}
	
}
