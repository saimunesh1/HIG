//
//  PolicyPaymentCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PolicyPaymentCell: UITableViewCell {
    var dashboardInfo: DashboardResponse? {
        didSet {
            updateView()
        }
    }
    
    @IBOutlet var amountDueDateLabel: UILabel?
    @IBOutlet var amountDueLabel: UILabel?
    
    @IBAction func didTouchPayButton(_ sender: UIButton) {
        ApplicationContext.shared.navigator.replace("pgac://payments", context: nil, wrap: BaseNavigationController.self)
    }
    
    private func updateView() {
        amountDueDateLabel?.text = nil
        amountDueLabel?.text = nil
        
        if let currentDueAmount = dashboardInfo?.currentDueAmount?.rawValue as? NSNumber,
            let currentDueDate = dashboardInfo?.currentDueDate {
            
            amountDueDateLabel?.text = String(format: NSLocalizedString("dashboard.policyinfo.amountdue", comment: "Amount Due"), DateFormatter.shortMonthDay.string(from: currentDueDate))
            amountDueLabel?.text = NumberFormatter.currency.string(from: currentDueAmount)
        }
    }
}
