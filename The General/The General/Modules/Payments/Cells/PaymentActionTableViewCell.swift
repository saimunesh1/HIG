//
//  PaymentActionTableViewCell.swift
//  The General
//
//  Created by Derek Bowen on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PaymentActionTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
