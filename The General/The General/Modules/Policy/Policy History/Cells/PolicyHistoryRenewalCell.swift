//
//  PolicyHistoryRenewalCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/5/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PolicyHistoryRenewalCell: UITableViewCell {
    
    var policyHistoryResponse: PolicyHistoryResponse? = nil {
        didSet {
            updateCell()
        }
    }
    
    @IBOutlet weak fileprivate var descriptionLabel: UILabel!
    @IBOutlet weak fileprivate var processDateLabel: UILabel!
    @IBOutlet weak fileprivate var effectiveDateLabel: UILabel!
    @IBOutlet weak fileprivate var amountLabel: UILabel!
    
    @IBAction func viewDocumentButtonTapped(_ sender: UIButton) {
    
    }
    
    override func prepareForReuse() {
        descriptionLabel.text = "-"
        processDateLabel.text = "-"
        effectiveDateLabel.text = "-"
        amountLabel.text = "-"
    }
    
    private func updateCell() {
        if let description = policyHistoryResponse?.description {
            descriptionLabel.text = description
        }
        
        if let effectiveDate = policyHistoryResponse?.effectiveDate {
            effectiveDateLabel.text = DateFormatter.shortMonthDay.string(from: effectiveDate)
        }

        if let noticedOnDate = policyHistoryResponse?.noticedOn {
            processDateLabel.text = DateFormatter.shortMonthDay.string(from: noticedOnDate)
        }

        if let amountString = policyHistoryResponse?.amount {
            let amount = (amountString as NSString).doubleValue
            amountLabel.text = NumberFormatter.currency.string(from: (amount as NSNumber))
        }
    }
}
