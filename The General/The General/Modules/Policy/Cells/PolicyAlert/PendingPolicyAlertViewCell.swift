//
//  PendingPolicyAlertViewCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PendingPolicyAlertViewCell: UITableViewCell {

    @IBOutlet weak var warningImageView: UIImageView!
    @IBOutlet weak var lblwarning: UILabel!
    @IBOutlet weak var lblwarningSubtitle: UILabel!
    
    var dashboardResponse: DashboardResponse? {
        didSet {
            updateValues()
        }
    }
    
    var paymentResponse: PaymentsGetDueDetailsResponse? {
        didSet {
            updateValues()
        }
    }
    
    private func updateValues() {
        if let dashResp = dashboardResponse, let status = dashResp.policyStatus, let _ = paymentResponse {
            
            if status == .canceled {
                warningImageView.tintColor = .tgRed
                lblwarning.text = NSLocalizedString("policydetails.warnings.cancelled", comment: "")
                lblwarningSubtitle.text = NSLocalizedString("policydetails.warnings.cancelled.subtitle", comment: "")
            } else if status == .entry {
                warningImageView.tintColor = .tgYellow
                lblwarning.text = NSLocalizedString("policydetails.warnings.entry", comment: "")
                lblwarningSubtitle.text = nil

            } else if status == .lapsed {
                warningImageView.tintColor = .tgYellow
                lblwarning.text = NSLocalizedString("policydetails.warnings.lapsed", comment: "")
                lblwarningSubtitle.text = nil
            } else if status == .active {
                warningImageView.tintColor = .tgYellow
                if let endDate = dashboardResponse?.policyEndDate {
                    // TODO: need to be updated as per
                    if let days = endDate.daysBetween(), days > 5 && days < 15 {//TODO: This value need to be cahnge
                        lblwarning.text = NSLocalizedString("policydetails.warnings.active", comment: "")
                        lblwarningSubtitle.text = nil
                    }else if let days = endDate.daysBetween(), days >= 0 && days < 5 {
                        lblwarning.text = String(format: NSLocalizedString("policydetails.warnings.missed", comment: ""), String(describing: endDate.withTodaysYearMonthDay()))
                        lblwarningSubtitle.text = NSLocalizedString("policydetails.warnings.active.sub", comment: "")
                    }
                }
            }
        }
    }
}
