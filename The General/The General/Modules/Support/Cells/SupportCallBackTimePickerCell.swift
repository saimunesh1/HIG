//
//  SupportCallBackTimePickerCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/5/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

protocol SupportCallBackTimePickerCellDelegate: class {
	func didSelect(callBackTimeWindow: CallBackTimeWindow)
}

class SupportCallBackTimePickerCell: BaseTableViewCell {

	@IBOutlet weak var timePickerView: UIPickerView!

	public var callBackTimeWindows = [CallBackTimeWindow]() { didSet { timePickerView.reloadAllComponents() } }
	
	public weak var delegate: SupportCallBackTimePickerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
		timePickerView.dataSource = self
		timePickerView.delegate = self
    }

}

extension SupportCallBackTimePickerCell: UIPickerViewDataSource, UIPickerViewDelegate {
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return callBackTimeWindows.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return callBackTimeWindows[row].humanReadableDescription
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		delegate?.didSelect(callBackTimeWindow: callBackTimeWindows[row])
	}
	
}
