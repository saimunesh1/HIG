//
//  InfoTableViewCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol InfoTableViewCellDelegate {
	func didUpdate(index: Int, text: String)
	func didFinishUpdating(index: Int, text: String)
}

class InfoTableViewCell: BaseTableViewCell, UITextFieldDelegate {

	@IBOutlet weak var textField: UITextField!
	
	public var delegate: InfoTableViewCellDelegate?
	public var index = 0
	public var isPhoneNumberField = false {
		didSet {
			if isPhoneNumberField { setAsPhoneNumberField() }
		}
	}
	
	public var row: Row? {
		didSet {
			if let newRow = row {
				if newRow.field?.required == true, let text = newRow.field?.placeHolder {
					textField.attributedPlaceholder = Helper.requiredAttributedText(text: text)
				} else {
					textField.placeholder = newRow.field?.placeHolder?.initialCapped
				}
			}
		}
	}
	
	public var item: Field? {
		didSet {
			textField.placeholder = item?.placeHolder
		}
	}
    
    override func awakeFromNib() {
        super.awakeFromNib()
		textField.delegate = self
		textField.addTarget(self, action: #selector(fieldUpdated(textField: )), for: .editingChanged)
    }
	
	private func setAsPhoneNumberField() {
		textField.keyboardType = .phonePad
	}

	@objc private func fieldUpdated(textField: UITextField) {
		delegate?.didUpdate(index: index, text: textField.text ?? "")
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if string == "\n" {
			textField.resignFirstResponder()
			return false
		}
		if let oldString = textField.text {
			let newString = oldString.replacingCharacters(in: Range(range, in: oldString)!, with: string)
			return newString.count <= 10 || (newString.count <= 11 && newString.first == "1")
		}
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
		delegate?.didFinishUpdating(index: index, text: textField.text ?? "")
	}
	
	override func prepareForReuse() {
		textField.keyboardType = .default
	}

}
