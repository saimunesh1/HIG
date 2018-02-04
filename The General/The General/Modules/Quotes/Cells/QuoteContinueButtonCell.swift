//
//  QuoteContinueButtonCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol QuoteContinueButtonCellDelegate: class {
	func didPressContinue()
}

class QuoteContinueButtonCell: BaseTableViewCell {
	
	public weak var delegate: QuoteContinueButtonCellDelegate?

	@IBAction func didPressContinue(_ sender: Any) {
		delegate?.didPressContinue()
	}
	
}
