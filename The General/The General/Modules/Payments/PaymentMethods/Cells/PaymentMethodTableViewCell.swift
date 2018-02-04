//
//  PaymentMethodTableViewCell.swift
//  The General
//
//  Created by Derek Bowen on 10/19/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PaymentMethodTableViewCell: UITableViewCell {
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkImageView.tintColor = .tgGreen
    }

    func setup(withPaymentMethod paymentMethod: PaymentMethodResponse) {
        switch paymentMethod.type {
        case .card:
            self.iconImageView.image = #imageLiteral(resourceName: "24px__credit-card")
            self.titleLabel.text = String(format: NSLocalizedString("Credit card ending in %@", comment: ""), paymentMethod.last4Digits)
            
            if let expirationMonth = paymentMethod.month, let expirationYear = paymentMethod.year {
                self.detailLabel.text = String(format: NSLocalizedString("Exp. %i/%i", comment: ""), expirationMonth, expirationYear)
            }
            
            if let label = paymentMethod.label, !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.detailLabel.text = (self.titleLabel.text ?? "") + ", " + (self.detailLabel.text ?? "")
                self.titleLabel.text = label
            }
            
        case .bankAccount:
            self.iconImageView.image = #imageLiteral(resourceName: "24px__bank")
            self.titleLabel.text = String(format: NSLocalizedString("Account ending in %@", comment: ""), paymentMethod.last4Digits)
            
            if let label = paymentMethod.label, !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.detailLabel.text = self.titleLabel.text
                self.titleLabel.text = label
            }
            else {
                self.detailLabel.text = nil
            }
        }
        
        if paymentMethod.preferred {
            let title = NSMutableAttributedString(string: self.titleLabel.text! + " ")
            let preferredText = NSAttributedString(string: NSLocalizedString("(default)", comment: ""), attributes: [.font: UIFont.lightTitle])
            title.append(preferredText)
            
            self.titleLabel.attributedText = title
        }
    }
}
