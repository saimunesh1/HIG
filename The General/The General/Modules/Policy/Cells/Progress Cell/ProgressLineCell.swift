//
//  ProgressLineCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class ProgressLineCell: UITableViewCell {

    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    @IBOutlet weak var lblEffective: UILabel!
    @IBOutlet weak var lblExpires: UILabel!
    @IBOutlet weak var policyDateStatus: PolicyDateCompletionLineView!

    var dashboardInfo: DashboardResponse? {
        didSet {
            updateView()
        }
    }

    private func updateView() {
        
        policyDateStatus?.dashboardInfo = dashboardInfo
        if let dashboardInfo = dashboardInfo, dashboardInfo.isExpiredPolicy {
            lblExpires?.text = NSLocalizedString("dashboard.policyinfo.expired", comment: "Expired")
            lblExpires?.textColor = UIColor.tgRed
        } else {
            lblExpires?.text = NSLocalizedString("dashboard.policyinfo.expires", comment: "Expires")
            lblExpires?.textColor = UIColor.tgTextFontColor
        }
        if let effectiveDate = dashboardInfo?.policyEffectiveDate, let endDate = dashboardInfo?.policyEndDate {
            lblStartDate?.text = DateFormatter.shortMonthDayYear.string(from: effectiveDate)
            lblEndDate?.text = DateFormatter.shortMonthDayYear.string(from: endDate)
        }
    }

}
