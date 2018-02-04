//
//  PaymentDueCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PaymentDueCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPaymentDue: UILabel!
    @IBOutlet weak var paynowBtn: UIButton!
    var btnTouched: (()-> ())?
    
    var dashboardInfo: DashboardResponse? {
        didSet {
            updateView()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.paynowBtn.layer.cornerRadius = self.paynowBtn.frame.height / 2.0

    }
    
    private func updateView() {
        guard let dashInfo = dashboardInfo else { return }
		if let currentDueAmount = dashInfo.currentDueAmount?.rawValue as NSNumber?,
            let currentDueDate = dashInfo.currentDueDate {
            lblTitle?.text = String(format: NSLocalizedString("dashboard.policyinfo.amountdue", comment: "Amount Due"), DateFormatter.shortMonthDay.string(from: currentDueDate))
            lblPaymentDue?.text = NumberFormatter.currency.string(from: currentDueAmount)
        }
    }
    
    @IBAction func payNowTouched(_ sender: UIButton) {
        btnTouched?()
    }
    
}
