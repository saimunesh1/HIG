//
//  PolicyRenewCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PolicyRenewCell: UITableViewCell {
    var dashboardInfo: DashboardResponse? {
        didSet {
            updateView()
        }
    }
    
    @IBOutlet var warningImageView: UIImageView?
    @IBOutlet var expiredLabel: UILabel?

    @IBAction func didTouchPayButton(_ sender: UIButton) {
        ApplicationContext.shared.navigator.replace("pgac://payments", context: nil, wrap: BaseNavigationController.self)
    }
    
    override func awakeFromNib() {
        warningImageView?.tintColor = .tgRed
    }
    
    private func updateView() {
        expiredLabel?.text = nil
        
        if let expirationDate = dashboardInfo?.currentDueDate {
            let datestamp = DateFormatter.monthDayYear.string(from: expirationDate)
            let timestamp = DateFormatter.hourMinuteMeridiemTimezone.string(from: expirationDate)

            expiredLabel?.text = String(format: NSLocalizedString("dashboard.policyinfo.policyExpired", comment: "Policy expired"), datestamp, timestamp)
        }
    }
}
