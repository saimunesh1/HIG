//
//  QuoteExistingQuoteCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol QuoteExistingQuoteCellDelegate: class {
	func didTapCell(quote: QuoteResponse?)
}

class QuoteExistingQuoteCell: BaseTableViewCell {

	@IBOutlet weak var shadowedBackgroundView: UIView!
	@IBOutlet weak var vehicleDescriptionLabel: UILabel!
	@IBOutlet weak var dateAndTimeLabel: UILabel!
	@IBOutlet weak var continueApplicationLabel: UILabel!
	@IBOutlet weak var continueApplicationLabelTopConstraint: NSLayoutConstraint!
	
	public weak var delegate: QuoteExistingQuoteCellDelegate?
	public var quote: QuoteResponse? {
		didSet {
            if let quoteDateString = quote?.date, let date = DateFormatter.iso8601.date(from: quoteDateString) {
				dateAndTimeLabel.text = DateFormatter.fullDateTime.string(from: date)
            } else {
                dateAndTimeLabel.text = nil
            }

            updateContinueApplicationLabel()
		}
	}

	private let shadowOffset: CGFloat = 5.0
	private var tapGestureRecognizer: UITapGestureRecognizer?
	
	override func awakeFromNib() {
        super.awakeFromNib()
		shadowedBackgroundView.layer.shadowColor = UIColor.black.cgColor
		shadowedBackgroundView.layer.shadowOffset = CGSize(width: -shadowOffset / 2.0, height: shadowOffset / 2.0)
		shadowedBackgroundView.layer.shadowRadius = shadowOffset
		shadowedBackgroundView.layer.shadowOpacity = 0.3
		continueApplicationLabel.textColor = .tgGreen
		continueApplicationLabel.text = ""
		dateAndTimeLabel.textColor = .tgTextFontColor
		updateContinueApplicationLabel()
    }
	
	private func updateContinueApplicationLabel() {
        let allowContinueApplication = quote?.allowsContinuingOfApplication ?? false
        
		if let quoteDateString = quote?.date, let date = DateFormatter.iso8601.date(from: quoteDateString) {
			dateAndTimeLabel.text = DateFormatter.fullDateTime.string(from: date)
        }
		
		// TODO: What if there's' more than one vehicle?
		if let vehicle = quote?.quoteVehicles?[0] {
			vehicleDescriptionLabel.text = vehicle.yearMakeAndModel
		}
		continueApplicationLabel.text = (allowContinueApplication ? "Continue application" : "")
		continueApplicationLabelTopConstraint.constant = (allowContinueApplication ? 10.0 : 0.0)
		if allowContinueApplication {
			tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
			addGestureRecognizer(tapGestureRecognizer!)
		}
	}

	@objc func didTapCell() {
		delegate?.didTapCell(quote: quote)
	}

}
