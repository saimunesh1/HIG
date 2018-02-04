//
//  SupportCallbackCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

protocol SupportCallbackCellDelegate: class {
	func didPressCancelCall()
}

class SupportCallBackCell: BaseTableViewCell {

	@IBOutlet weak var cancelLabel: UILabel!
	@IBOutlet weak var phoneNumberLabel: UILabel!
	@IBOutlet weak var separatorView: UIView!
	@IBOutlet weak var timeLabel: UILabel!
	
	public weak var delegate: SupportCallbackCellDelegate?
	
	override func awakeFromNib() {
        super.awakeFromNib()
		cancelLabel.textColor = .tgRed
		separatorView.backgroundColor = .tgGray
    }

	@IBAction func didPressCancelCall(_ sender: Any) {
		delegate?.didPressCancelCall()
	}
	
}
