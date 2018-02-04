//
//  AgentInfoCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/4/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class AgentInfoCell: UITableViewCell {

    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblAddressVal: UILabel!
    @IBOutlet weak var lblPhoneVal: UILabel!
    @IBOutlet weak var lblEmailVal: UILabel!
    
    var agentInfo: AgentResponse? {
        didSet {
            updateCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    private func updateCell() {
    
        if let agentName = agentInfo?.agentName, let agentAddress = agentInfo?.agentAddress {
            lblAddressVal.text = "\(agentName)\n\(agentAddress)"
        }
        lblPhoneVal.text = agentInfo?.agentPhone
        lblEmailVal.text = agentInfo?.agentEmail
    }

}
