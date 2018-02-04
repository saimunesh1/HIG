//
//  DriverViolationsCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/8/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class DriverViolationsCell: UITableViewCell {

    @IBOutlet weak var lblOccurenceValue: UILabel!
    @IBOutlet weak var lblTypeValue: UILabel!
    @IBOutlet weak var lblConvictionValue: UILabel!
    @IBOutlet weak var lblChangeThroughVal: UILabel!
    @IBOutlet weak var lblPointsValue: UILabel!
    @IBOutlet weak var lblTermValue: UILabel!
    
    var driverViolation: DriverViolations? {
        didSet {
            updateValues()
        }
    }
    
    private func updateValues() {
        guard let violation = driverViolation else { return }
        lblOccurenceValue.text = DateFormatter.monthDayYearStyle.string(from: violation.occurredOn)
        lblTypeValue.text = violation.description
        if let date = DateFormatter.monthDayYearStyle.date(from: violation.convictedOn) {
            lblConvictionValue.text = DateFormatter.monthDayYearStyle.string(from: date)
        } else {
            lblConvictionValue.text = "-"
        }
        lblChangeThroughVal.text = DateFormatter.monthDayYearStyle.string(from: violation.chargeThroughDate)
        lblPointsValue.text = violation.points
        lblTermValue.text = violation.term
    }
}
