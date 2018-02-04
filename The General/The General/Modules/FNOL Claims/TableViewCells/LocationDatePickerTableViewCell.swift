//
//  LocationDatePickerTableViewCell.swift
//  The General
//
//  Created by Michael Moore on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol LocationDatePickerCellDelegate {
    func datePicked(date: String, field: Field?)
}

class LocationDatePickerTableViewCell: DatePickerCell {

    var delegate: LocationDatePickerCellDelegate?
    
    override func awakeFromNib() {
        self.selectionStyle = .none

    }
    
    func setCurrentDate() {
        guard let type = self.field?.type, let cellType = CellType(rawValue: type) else { return }
        let formatter = getDisplayFormatterStyle(type: cellType)
        let dateString = formatter.string(from: datePicker.date)
        valueField.text = dateString
    }
    
    @IBAction override func datePickerAction(sender: AnyObject) {
        guard let type = self.field?.type, let cellType = CellType(rawValue: type)  else { return }
        let formatter = getDisplayFormatterStyle(type: cellType)
        let dateString = formatter.string(from: datePicker.date)
        self.valueField.text = dateString
        delegate?.datePicked(date: dateString, field: field)
    }
    
}
