//
//  SupportCallBackTimeCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/8/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

protocol SupportCallBackTimeCellDelegate: class {
	func didPressTimeButton()
}

class SupportCallBackTimeCell: BaseTableViewCell {

	@IBOutlet weak var timeLabel: UILabel!
	public weak var delegate: SupportCallBackTimeCellDelegate?

	override func awakeFromNib() {
        super.awakeFromNib()
		timeLabel.textColor = .tgGreen
    }

	@IBAction func didPressTimeButton(_ sender: Any) {
		delegate?.didPressTimeButton()
	}
	
}
