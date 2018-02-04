//
//  CoverageInfoCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 06/01/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class CoverageInfoCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDeductibleVal: UILabel!
    @IBOutlet weak var lblCoverageVal: UILabel!
    
    var coverageInfo: CoverageTypes? {
        didSet {
            updateValues()
        }
    }
    
    private func updateValues() {
        if let coverageInfo = coverageInfo {
            lblTitle.text = coverageInfo.description
            lblDeductibleVal.text = coverageInfo.deductible
            lblCoverageVal.text = coverageInfo.limits
        }
    }
}
