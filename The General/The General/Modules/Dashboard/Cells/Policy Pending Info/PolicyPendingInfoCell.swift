//
//  PolicyPendingInfoCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/20/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PolicyPendingInfoCell: UITableViewCell {
    var dashboardInfo: DashboardResponse? {
        didSet {
            updateView()
        }
    }
    
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var policyNumberLabel: UILabel!
    @IBOutlet var warningImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        warningImageView.tintColor = .tgYellow
    }
    
    private func updateView() {
        welcomeLabel.text = nil
        policyNumberLabel.text = nil
        
        if let policyNumber = SessionManager.policyNumber {
            policyNumberLabel.text = policyNumber
        }
        
        if let dashboardInfo = dashboardInfo {
            if let insuredName = dashboardInfo.insuredName {
                welcomeLabel.text = String(format: NSLocalizedString("dashboard.pendingpolicyinfo.hi_name", comment: "Hi!"), insuredName)
            } else {
                welcomeLabel.text = NSLocalizedString("dashboard.pendingpolicyinfo.hi", comment: "Hi!")
            }
        }
    }
}
