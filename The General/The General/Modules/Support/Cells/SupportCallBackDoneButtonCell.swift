//
//  SupportCallBackDoneButtonCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/5/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

protocol SupportCallBackDoneButtonCellDelegate: class {
	func didPressDone()
}

class SupportCallBackDoneButtonCell: BaseTableViewCell {
	
	@IBOutlet weak var doneButton: BorderUIButton!
	
	public var phoneNumberIsValid = false { didSet { doneButton.isEnabled = phoneNumberIsValid } }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		doneButton.isEnabled = false
	}
	
	public weak var delegate: SupportCallBackDoneButtonCellDelegate?
	
	@IBAction func didPressDone(_ sender: Any) {
		delegate?.didPressDone()
	}
	
}
