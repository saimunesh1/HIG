//
//  FullPolicyInfoCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class FullPolicyInfoCell: UITableViewCell {

    var dashboardInfo: DashboardResponse? {
        didSet {
            updateView()
        }
    }

    @IBOutlet weak var lblInsuredTitle: UILabel!
    @IBOutlet weak var lblPolicyTitle: UILabel!
    @IBOutlet weak var lblInsuredValue: UILabel!
    @IBOutlet weak var lblPolicyValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }
    
    private func updateView() {
        if let policyNumber = SessionManager.policyNumber {
            lblPolicyValue?.text = policyNumber
        }
        if let insured = dashboardInfo?.insuredName {
            lblInsuredValue.text = insured
        }
    }

}
