//
//  YearPicker.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/31/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class YearPicker: BaseTableViewCell {
    
	@IBOutlet var errorLabel: UILabel!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var picker: UIPickerView!
	@IBOutlet weak var yearTextField: UITextField!
	
	var callback: ((String) -> ())?
    var item: Field?
	
    var yearsTillNow: [String] {
        var years = [String]()
		years.append(YearPicker.iDontKnow)
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        for i in (1950..<year + 1).reversed() {
            years.append("\(i)")
        }
        return years
    }
	
	static let iDontKnow = "I don't know"
    
    override func awakeFromNib() {
        super.awakeFromNib()
		titleLabel.text = NSLocalizedString("vehicleinfo.year", comment: "Year")
		yearTextField.textColor = .tgTextFontColor
        picker.delegate = self
    }
	
}

extension YearPicker: UIPickerViewDataSource, UIPickerViewDelegate {
	
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return yearsTillNow.count }
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return yearsTillNow[row] }
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { callback?(yearsTillNow[row]) }

}
