//
//  ClaimsDamagedPartsCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/20/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsDamagedPartsCell: BaseTableViewCell {

	@IBOutlet weak var partsListLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		partsListLabel.textColor = .tgTextFontColor
    }
    
}
