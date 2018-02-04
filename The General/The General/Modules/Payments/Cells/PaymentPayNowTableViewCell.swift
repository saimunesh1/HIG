//
//  PaymentPayNowTableViewCell.swift
//  The General
//
//  Created by Derek Bowen on 10/11/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PaymentPayNowTableViewCell: UITableViewCell {
    @IBOutlet weak var payNowButton: UIButton!
    
    var actionHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        self.payNowButton.layer.cornerRadius = self.payNowButton.frame.height / 2.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didTouchPayNow(_ sender: Any) {
        self.actionHandler?()
    }
    
    func setup(withDueDetails dueDetails: PaymentsGetDueDetailsResponse) {
        guard let status = dueDetails.status else { return }
        switch status {
        case .active:
            break
            
        default:
            break
        }
    }
}
