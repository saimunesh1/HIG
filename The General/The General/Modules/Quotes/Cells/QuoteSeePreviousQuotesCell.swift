//
//  QuoteSeePreviousQuotesCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol QuoteSeePreviousQuotesCellDelegate: class {
	func didTapSeePreviousQuotesCell()
}

class QuoteSeePreviousQuotesCell: BaseTableViewCell {
	
	@IBOutlet weak var label: UILabel!
	
	public weak var delegate: QuoteSeePreviousQuotesCellDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		label.textColor = .tgGreen
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
		addGestureRecognizer(tapGestureRecognizer)
	}
	
	@objc func didTapCell() {
		delegate?.didTapSeePreviousQuotesCell()
	}

}
