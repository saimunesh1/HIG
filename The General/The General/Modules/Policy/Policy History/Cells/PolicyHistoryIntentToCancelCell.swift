//
//  PolicyHistoryIntentToCancelCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/5/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PolicyHistoryIntentToCancelCell: UITableViewCell {
    
    var policy: Any? {
        didSet {
            updateCell()
        }
    }
    
    @IBOutlet weak fileprivate var processDateLabel: UILabel!
    @IBOutlet weak fileprivate var effectiveDateLabel: UILabel!
    @IBOutlet weak fileprivate var amountLabel: UILabel!
    
    @IBAction func viewDocumentButtonTapped(_ sender: UIButton) {
        
    }
    
    private func updateCell() {
        processDateLabel.text = DateFormatter.shortMonthDay.string(from: Date())
        effectiveDateLabel.text = DateFormatter.shortMonthDay.string(from: Date())
        amountLabel.text = NumberFormatter.currency.string(from: 0.0)
    }
}
