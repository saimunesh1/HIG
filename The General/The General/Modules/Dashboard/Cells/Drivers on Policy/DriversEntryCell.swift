//
//  DriversEntryCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class DriversEntryCell: UITableViewCell {
    @IBOutlet var driverLabel: UILabel!
    @IBOutlet var vehicleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        driverLabel.text = ""
        vehicleLabel.text = ""
    }
}
