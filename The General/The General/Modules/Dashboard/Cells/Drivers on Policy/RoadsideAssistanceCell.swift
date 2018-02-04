//
//  RoadsideAssistanceCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/20/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class RoadsideAssistanceCell: UITableViewCell {

    @IBOutlet var phoneNumberButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let formattedPhoneNumber = ApplicationContext.shared.phoneCallManager.roadsideAssistanceNumber.displayNumber
        phoneNumberButton.setTitle(formattedPhoneNumber, for: .normal)
    }
    
    @IBAction func didTouchPhoneNumberButton(_ sender: UIButton) {
        ApplicationContext.shared.phoneCallManager.callRoadsideAssistance()
    }
}
