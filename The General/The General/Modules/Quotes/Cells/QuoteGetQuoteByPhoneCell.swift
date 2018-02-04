//
//  QuoteGetQuoteByPhoneCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol QuoteGetQuoteByPhoneCellDelegate: class {
	func didPressGetQuoteByPhone()
}

class QuoteGetQuoteByPhoneCell: BaseTableViewCell {
	
	@IBOutlet weak var label: UILabel!
	
	public weak var delegate: QuoteGetQuoteByPhoneCellDelegate?
	public var leftAlign = false {
		didSet {
			label.textAlignment = leftAlign ? .left : .center
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
		let cellAttributedString = NSMutableAttributedString(string: "You can also get a quote by phone.")
		cellAttributedString.setColorForText("phone", with: .tgGreen)
		label.attributedText = cellAttributedString
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressGetQuoteByPhone))
		addGestureRecognizer(tapGestureRecognizer)
    }
	
	@objc func didPressGetQuoteByPhone() {
		delegate?.didPressGetQuoteByPhone()
	}

}
