//
//  MakePaymentCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 11/01/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class MakePaymentCell: UITableViewCell {

    @IBOutlet weak var lblMinAmountDesc: UILabel!
    @IBOutlet weak var lblMinAmountDue: UILabel!
    @IBOutlet weak var lblFullRenewalDesc: UILabel!
    @IBOutlet weak var lblFullRenewal: UILabel!
    @IBOutlet weak var lblFullPayoff: UILabel!
    @IBOutlet weak var lblFullPayoffDesc: UILabel!
    @IBOutlet weak var btnMakePayment: UIButton!
    var buttonTouched: (()-> Void)?
    
    var paymentResponse: PaymentsGetDueDetailsResponse? {
        didSet {
            updateValues()
        }
    }
    var dashboardInfo: DashboardResponse? {
        didSet {
            updateValues()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnMakePayment.layer.cornerRadius = self.btnMakePayment.frame.height / 2.0
        
    }
    
    private func updateValues() {
        if let payment = paymentResponse, let dashResp = dashboardInfo, let status = dashResp.policyStatus {
            
            if let minPay = payment.minimumPayment?.rawValue as NSNumber?, let current = payment.currentAmountDue?.rawValue as NSNumber?, let renewal = payment.paidInFullRenewalAmount?.rawValue as NSNumber? {
                
                btnMakePayment.setTitle(NSLocalizedString("policydetails.app.reinstate", comment: ""), for: .normal)
                lblMinAmountDesc.text = payment.currentAmountDueLabel
                lblMinAmountDue.text = NumberFormatter.currency.string(from: minPay)
                lblFullRenewalDesc.text = payment.renewalDownPaymentPlusCurrentDueAmountLabel
                lblFullRenewal.text = NumberFormatter.currency.string(from: current)
                lblFullPayoffDesc.text = payment.paidInFullRenewalAmountLabel
                lblFullPayoff.text = NumberFormatter.currency.string(from: renewal)
                if status == .canceled {
                    lblMinAmountDue.textColor = .tgRed
                }
                if status == .active {
                    btnMakePayment.setTitle(NSLocalizedString("policydetails.app.makePayment", comment: ""), for: .normal)
                }
            }
        }
    }
    
    @IBAction func btnTouched(_ sender: UIButton) {
        buttonTouched?()
    }
}
