//
//  QuoteTextCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class QuoteTextCell: BaseTableViewCell {
	
	@IBOutlet weak var label: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        label.text = "Getting a quick free quote from The General takes just a few simple steps.\nLet's get started!"
    }
	
}
