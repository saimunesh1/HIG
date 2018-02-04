//
//  ClaimSummaryDetailsCell.swift
//  The General
//
//  Created by Trevor Alyn on 11/9/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimSummaryDetailsCell: BaseTableViewCell {

	@IBOutlet weak var leftLabel: UILabel!
	@IBOutlet weak var detailsLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		detailsLabel.textColor = .tgTextFontColor
	}
	
	public var row: SummaryRow? {
		didSet {
			leftLabel.text = row?.leftLabelText
			detailsLabel.text = row?.rightLabelText
		}
	}

}
