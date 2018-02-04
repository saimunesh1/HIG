//
//  PaymentScheduleTableViewCell.swift
//  The General
//
//  Created by Derek Bowen on 10/11/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PaymentScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var schedulePaymentButton: UIButton!

    var actionHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTouchSchedulePayment(_ sender: Any) {
        self.actionHandler?()
    }
    
    func setup(withDueDetails dueDetails: PaymentsGetDueDetailsResponse) {
        
        if dueDetails.autoDebitEnabled {
            self.schedulePaymentButton.setTitle(NSLocalizedString("payments.ui.scheduleadifferentday", comment: ""), for: .normal)
            
        } else {
            self.schedulePaymentButton.setTitle(NSLocalizedString("payments.ui.scheduleonetime", comment: ""), for: .normal)
        }
        
        // Lapsed
        if dueDetails.status == .lapsed {
            // Eligible for reinstatement
            if !dueDetails.displayNonRenewableFullPayoffAmountOption {
                if let dueDate = dueDetails.currentDueDate {
                    let dueDateString = DateFormatter.monthDay.string(from: dueDate)
                    self.titleLabel.text = String(format: NSLocalizedString("Your policy is lapsed due to nonpayment. If you pay your balance before %@ your policy will be reinstated.", comment: ""), dueDateString)
                }
            }
            else {
                // Balance due
                if let currentAmountDue = dueDetails.currentAmountDue?.rawValue,
                    currentAmountDue > 0 {
                    self.titleLabel.text = NSLocalizedString("Your policy is no longer eligible for reinstatement. Please pay your account balance now. Unpaid balances will be sent to collections.", comment: "")
                }
                else {
                    self.titleLabel.text = NSLocalizedString("Your policy is no longer eligible for reinstatement.", comment: "")
                    self.schedulePaymentButton.setTitle(NSLocalizedString("Get a fast free quote now.", comment: ""), for: .normal)
                }
            }
        }
    }
}
