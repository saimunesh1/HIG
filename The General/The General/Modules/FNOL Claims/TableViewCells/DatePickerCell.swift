//
//  DatePickerCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol DatePickerCellDelegate {
	func didPickDate(date: Date, field: Field?, row: Row?)
}

class DatePickerCell: BaseTableViewCell {

    @IBOutlet var valueField: UITextField!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
	
	public var datePickerDelegate: DatePickerCellDelegate?
	public var field: Field!
	public var row: Row?
	
	@IBAction func datePickerAction(sender: AnyObject) {
		updateDate(date: self.datePicker.date)
	}
	
	public func setMinMaxDate() {
        let calendar = Calendar.current
        var minDateComponent = calendar.dateComponents([.day, .month, .year], from: Date())
        minDateComponent.day = 01
        minDateComponent.month = 01
        minDateComponent.year = 1900
        let minDate = calendar.date(from: minDateComponent)
        self.datePicker.minimumDate = minDate! as Date
        self.datePicker.maximumDate =  Date()
    }
	
	// Set ONLY the day/month/year components, so maxDate will work properly
	public func setDateForTime(date: Date) {
		let calendar = Calendar.current
		var inDateComponents = calendar.dateComponents([.day, .month, .year], from: date)
		var datePickerTimeComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: datePicker.date)
		datePickerTimeComponents.day = inDateComponents.day
		datePickerTimeComponents.month = inDateComponents.month
		datePickerTimeComponents.year = inDateComponents.year
		if let newDate = calendar.date(from: datePickerTimeComponents) {
			// Set the datePicker to a date that has the new date's year/month/day, but the picker's hour/minute
			if let type = self.field?.typeEnum, type == .datePicker {
				updateDate(date: newDate)
			}
		}
	}
	
	public func updateDate(date: Date) {
		var newDate = date
		if let maxDate = datePicker.maximumDate, newDate > maxDate { newDate = maxDate }
		if let minDate = datePicker.minimumDate, newDate < minDate { newDate = minDate }
		datePicker.date = newDate
		let dateStr = getDisplayDate(forDate: newDate) as String
		valueField.text = dateStr
		let storageDateString = getStorageDate(forDate: newDate)
		ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(storageDateString, displayValue: nil, forResponseKey: field.responseKey!)
		datePickerDelegate?.didPickDate(date: datePicker.date, field: field, row: row)
	}
	
    public func fetchSavedvalues() {
		if let responseKey = self.field.responseKey, let code = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: responseKey), let type = field.type, let cellType = CellType(rawValue: type) {
			let dateFormatter = getStorageFormatterStyle(type: cellType)
			if let date = dateFormatter.date(from: code) {
				datePicker.date = date
				valueField.text = getDisplayDate(forDate: date)
			}
        } else {
            self.valueField.placeholder = self.field.placeHolder
        }
    }
    
    public func checkForRequired() {
        if self.field.required {
            titleLabel.attributedText = Helper.requiredAttributedText(text:self.field.label!)
        } else {
            titleLabel.text = self.field.label
        }
    }
    
	public func getDisplayDate(forDate: Date) -> String {
		guard let type = self.field?.typeEnum else { return "" }
		let formatter = getDisplayFormatterStyle(type: type)
		switch type {
		case .timePicker:
			return "Around \(formatter.string(from: forDate))"
		default:
			return formatter.string(from: forDate)
		}
	}
	
	public func getStorageDate(forDate: Date) -> String {
		guard let type = self.field?.typeEnum else { return "" }
		let formatter = getStorageFormatterStyle(type: type)
		return formatter.string(from: forDate)
	}
	
    public func getDisplayFormatterStyle(type: CellType) -> DateFormatter {
        let formatter = DateFormatter()
        switch type {
        case .timePicker:
            formatter.locale = NSLocale.current
            formatter.timeZone = NSTimeZone.local
            formatter.timeStyle = .long
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            formatter.dateFormat = "hh:mm a zzz"
        case .datePicker:
            formatter.dateStyle = DateFormatter.Style.long
        default:()
        }
        return formatter
    }
	
	public func getStorageFormatterStyle(type: CellType) -> DateFormatter {
		switch type {
		case .timePicker:
			return DateFormatter.hoursMilitary
		case .datePicker:
			return DateFormatter.twoDigitMonthDayFourDigitYear
		default:
			// This should never be hit
			return DateFormatter.twoDigitMonthDayFourDigitYear
		}
	}
	
}
