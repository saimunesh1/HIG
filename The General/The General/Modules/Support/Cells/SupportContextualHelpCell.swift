//
//  SupportContextualHelpCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/9/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class SupportContextualHelpCell: BaseTableViewCell {

	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
	
	public var contextualHelpString: String? { didSet { setUp() } }
	
	private func setUp() {
		textView.text = contextualHelpString
		let sizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
		textViewHeightConstraint.constant = sizeThatFits.height
	}

}
