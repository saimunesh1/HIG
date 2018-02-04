//
//  ClaimSummaryBasicCell.swift
//  The General
//
//  Created by Trevor Alyn on 11/9/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimSummaryBasicCell: BaseTableViewCell {

	@IBOutlet weak var leftLabel: UILabel!
	@IBOutlet weak var rightLabel: UILabel!
	@IBOutlet weak var rightSubLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		rightLabel.textColor = .tgTextFontColor
		rightSubLabel.textColor = .tgTextFontColor
	}
	
	public var row: SummaryRow? {
		didSet {
			leftLabel.text = row?.leftLabelText
			rightLabel.text = row?.rightLabelText
			rightSubLabel.text = row?.rightSubLabelText
		}
	}

}
