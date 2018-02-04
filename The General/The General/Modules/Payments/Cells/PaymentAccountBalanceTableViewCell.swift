//
//  PaymentAccountBalanceTableViewCell.swift
//  The General
//
//  Created by Derek Bowen on 10/11/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PaymentAccountBalanceTableViewCell: UITableViewCell {
    @IBOutlet weak var accountBalanceTitleLabel: UILabel!
    @IBOutlet weak var accountBalanceValueLabel: UILabel!
    @IBOutlet weak var schedulePaymentTitleLabel: UILabel!
    @IBOutlet weak var scheduledPaymentDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(withDueDetails dueDetails: PaymentsGetDueDetailsResponse) {
        // TODO: Don't disable these once we add scheduled payments
        self.schedulePaymentTitleLabel.isHidden = true
        self.scheduledPaymentDateLabel.isHidden = true
        
        if let accountBalance = dueDetails.fullPayoffAmount?.rawValue {
            self.accountBalanceValueLabel.text = NumberFormatter.currency.string(from: accountBalance as NSDecimalNumber)
            self.accountBalanceTitleLabel.isHidden = false
            self.accountBalanceValueLabel.isHidden = false
        }
        else {
            self.accountBalanceTitleLabel.isHidden = true
            self.accountBalanceValueLabel.isHidden = true
        }
    }

}
