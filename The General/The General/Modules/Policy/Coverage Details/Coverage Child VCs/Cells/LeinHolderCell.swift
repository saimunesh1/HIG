//
//  LeinHolderCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/9/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class LeinHolderCell: UITableViewCell {

    @IBOutlet weak var lblLeinHolder: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblAddedDate: UILabel!
    @IBOutlet weak var lblDeletedDate: UILabel!

    var leinHolder: VehicleLeinHolders? {
        didSet {
            updateValues()
        }
    }
    
    private func updateValues() {
        
        if let leinHolder = leinHolder {
            lblLeinHolder.text = "\(leinHolder.name)\n\(leinHolder.address)\n\(leinHolder.city), \(leinHolder.state) \(leinHolder.zip)"
            lblType.text = leinHolder.type
            lblAddedDate.text = DateFormatter.monthDayYear.string(from: leinHolder.dateAdded)
            if let deleted = leinHolder.dateDeleted, let date = DateFormatter.iso8601.date(from: deleted) {
                lblDeletedDate.text = DateFormatter.monthDayYear.string(from: date)
            } else {
                lblDeletedDate.text = "-"
            }
        }
    }
}
