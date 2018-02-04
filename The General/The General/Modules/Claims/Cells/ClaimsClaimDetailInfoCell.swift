//
//  ClaimsClaimDetailInfoCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsClaimDetailInfoCell: BaseTableViewCell {

	@IBOutlet weak var infoCellLabel: UILabel!
	
	public var isInteractive: Bool = false {
		didSet {
			infoCellLabel.textColor = isInteractive ? .tgGreen : .black
			infoCellLabel.font = isInteractive ? UIFont.boldTitle : UIFont.largeText
		}
	}
	
	override func prepareForReuse() {
		isInteractive = false
	}

}
