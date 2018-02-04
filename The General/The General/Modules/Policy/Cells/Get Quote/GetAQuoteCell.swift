//
//  GetAQuoteCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/10/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class GetAQuoteCell: UITableViewCell {

    var dashboardInfo: DashboardResponse? {
        didSet {
            updateView()
        }
    }
    @IBOutlet weak var lblPolicyWarning: UILabel!
    @IBOutlet weak var lblPolicySubWarning: UILabel!
    @IBOutlet weak var warningImage: UIImageView!
    
    override func awakeFromNib() {
        warningImage?.tintColor = .tgRed
    }

    @IBAction func getQuoteTouched(_ sender: CustomButton) {
        ApplicationContext.shared.navigator.replace("pgac://quotes", context: nil, wrap: BaseNavigationController.self)
    }
    
    private func updateView() {
        lblPolicyWarning?.text = nil
        
        if let expirationDate = dashboardInfo?.currentDueDate {
            let datestamp = DateFormatter.monthDayYear.string(from: expirationDate)
            let timestamp = DateFormatter.hourMinuteMeridiemTimezone.string(from: expirationDate)
            
            lblPolicyWarning?.text = String(format: NSLocalizedString("dashboard.policyinfo.policyExpired", comment: "Policy expired"), datestamp, timestamp)
        }
    }

}
