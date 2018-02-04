//
//  SubmitPaymentTableViewCell.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class SubmitPaymentTableViewCell: UITableViewCell {
    @IBOutlet var submitPaymentButton: UIButton!
    
    var actionHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didTouchSubmitPayment(_ sender: Any) {
        self.actionHandler?()
    }
}
