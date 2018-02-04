//
//  ClaimsClaimDetailTopCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/14/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsClaimDetailTopCell: BaseTableViewCell {
	
	@IBOutlet weak var topLabel: UILabel!
	@IBOutlet weak var bottomLabel: UILabel!
	
	public var claim: Claim? { didSet { setUpFromClaim() }}
	
	override func awakeFromNib() {
		resetLabels()
	}
	
	override func prepareForReuse() {
		resetLabels()
	}
	
	private func resetLabels() {
		topLabel.text = NSLocalizedString("claims.noaccidenttype", comment: "No accident type provided yet")
		bottomLabel.text = NSLocalizedString("claims.nodate", comment: "No date provided yet")
	}
	
	private func setUpFromClaim() {
		if let lossType = claim?.lossType, let city = claim?.city, let state = claim?.state, let lossDate = claim?.lossDate {
			topLabel.text = "\(lossType) in \(city.initialCapped), \(state)"
			bottomLabel.text = lossDate
		} else {
			resetLabels()
		}
	}
	
}
