//
//  SupportWeCallYouCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/5/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

protocol SupportWeCallYouCellDelegate: class {
	func update(phoneNumber: String)
}

class SupportWeCallYouCell: BaseTableViewCell {
	
	@IBOutlet weak var phoneNumberTextField: UITextField!
	@IBOutlet var dividers: [UIView]!
	
	public weak var delegate: SupportWeCallYouCellDelegate?
	
    override func awakeFromNib() {
        super.awakeFromNib()
		phoneNumberTextField.addTarget(self, action: #selector(phoneNumberTextFieldDidChange), for: .editingChanged)
		phoneNumberTextField.delegate = self
		dividers.forEach({ $0.backgroundColor = .tgGray })
    }
	
	@objc func phoneNumberTextFieldDidChange(field: UITextField) {
		delegate?.update(phoneNumber: field.text!)
	}
	
}

extension SupportWeCallYouCell: UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if let oldString = textField.text {
			let newString = oldString.replacingCharacters(in: Range(range, in: oldString)!, with: string)
			return newString.count <= 10 || (newString.count <= 11 && newString.first == "1")
		}
		return true
	}
	
}
