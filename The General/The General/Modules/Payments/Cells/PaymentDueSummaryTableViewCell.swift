//
//  PaymentDueSummaryTableViewCell.swift
//  The General
//
//  Created by Derek Bowen on 10/11/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PaymentDueSummaryTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(withDueDetails dueDetails: PaymentsGetDueDetailsResponse) {
        guard let dueDateDisplay = dueDetails.dueDateDisplay else { return }
        
        // - Title Label
        // If policy lapsed, is uneligable for reinstatement and has non-zero balance
        if dueDetails.status == .lapsed,
            let currentAmountDue = dueDetails.currentAmountDue?.rawValue,
            currentAmountDue > 0 {
            self.titleLabel.text = NSLocalizedString("Payment is due immediately", comment: "")
        }
        else {
            let amountDueMessageNormal = NSLocalizedString("Current amount due ", comment: "")
            let amountDueMessageBold = String(format: NSLocalizedString("before %@", comment: ""), dueDateDisplay)
            let boldFontAttributes: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.font: UIFont.boldTitle
            ]
            let amountDueMessage = NSMutableAttributedString(string: amountDueMessageNormal, attributes: nil)
            amountDueMessage.append(NSAttributedString(string: amountDueMessageBold, attributes: boldFontAttributes))
            self.titleLabel.attributedText = amountDueMessage
        }
        
        // - Amount due
        let amountDue: Decimal = dueDetails.currentAmountDue?.rawValue ?? 0
        self.amountLabel.text = NumberFormatter.currency.string(from: amountDue as NSDecimalNumber)
        
        
        
        
    }
}
