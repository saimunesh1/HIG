//
//  QuoteGetQuoteButtonCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol QuoteGetQuoteButtonCellDelegate: class {
	func didPressGetAQuote()
}

class QuoteGetQuoteButtonCell: BaseTableViewCell {
	
	public weak var delegate: QuoteGetQuoteButtonCellDelegate?

	@IBAction func didPressGetAQuote(_ sender: Any) {
		delegate?.didPressGetAQuote()
	}

}
