//
//  ClaimSummaryHeaderCell.swift
//  The General
//
//  Created by Trevor Alyn on 11/9/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimSummaryHeaderCell: BaseTableViewCell {

    @IBOutlet var titleLabel: UILabel!
	@IBOutlet weak var rightLabel: UILabel!
	
	public var row: SummaryRow? {
		didSet {
			titleLabel.text = row?.leftLabelText
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		rightLabel.textColor = .tgGreen
	}
	
}
