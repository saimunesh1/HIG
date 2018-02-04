//
//  PolicyInfoCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PolicyInfoCell: UITableViewCell {
    var dashboardInfo: DashboardResponse? {
        didSet {
            updateView()
        }
    }
    
    @IBOutlet var welcomeLabel: UILabel?
    @IBOutlet var policyNumberButton: UIButton?
    @IBOutlet var policyDateStatusView: PolicyDateStatusView?
    @IBOutlet var effectiveDateLabel: UILabel?
    @IBOutlet var expirationDatePromptLabel: UILabel?
    @IBOutlet var expirationDateLabel: UILabel?

    @IBAction func policyNumberTapped(_ sender: UIButton) {
        ApplicationContext.shared.navigator.replace("pgac://policy", context: nil, wrap: BaseNavigationController.self)
    }
    
    private func updateView() {
        welcomeLabel?.text = nil
        policyDateStatusView?.dashboardInfo = dashboardInfo
        effectiveDateLabel?.text = nil
        expirationDateLabel?.text = nil
        policyNumberButton?.setTitle("", for: .normal)

        if let policyNumber = SessionManager.policyNumber {
            policyNumberButton?.setTitle(policyNumber, for: .normal)
        }

        if let dashboardInfo = dashboardInfo {
            welcomeLabel?.text = String(format: NSLocalizedString("dashboard.policyinfo.welcome", comment: "Welcome back!"), dashboardInfo.insuredName ?? "")
            policyDateStatusView?.dashboardInfo = dashboardInfo
        }
        
        if let dashboardInfo = dashboardInfo, dashboardInfo.isExpiredPolicy {
            expirationDatePromptLabel?.text = NSLocalizedString("dashboard.policyinfo.expired", comment: "Expired")
            expirationDatePromptLabel?.textColor = UIColor.tgRed
        } else {
            expirationDatePromptLabel?.text = NSLocalizedString("dashboard.policyinfo.expires", comment: "Expires")
            expirationDatePromptLabel?.textColor = UIColor.tgTextFontColor
        }

        if let effectiveDate = dashboardInfo?.policyEffectiveDate, let endDate = dashboardInfo?.policyEndDate {
            effectiveDateLabel?.text = DateFormatter.shortMonthDayYear.string(from: effectiveDate)
            expirationDateLabel?.text = DateFormatter.shortMonthDayYear.string(from: endDate)
        }
    }
}
