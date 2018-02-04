//
//  PolicyHistoryHeaderCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/5/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PolicyHistoryHeaderCell: UITableViewCell {
    
    var year: String = "" {
        didSet {
            updateCell()
        }
    }
    
    @IBOutlet weak fileprivate var yearLabel: UILabel!
    
    private func updateCell() {
        yearLabel.text = year
    }
}
