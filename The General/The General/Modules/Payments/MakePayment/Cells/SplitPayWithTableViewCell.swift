//
//  SplitPayWithTableViewCell.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class SplitPayWithTableViewCell: UITableViewCell {
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var paymentAmountField: SplitPayField!
    @IBOutlet weak var paymentMethodButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.paymentAmountField.userSelected = false
    }
}
