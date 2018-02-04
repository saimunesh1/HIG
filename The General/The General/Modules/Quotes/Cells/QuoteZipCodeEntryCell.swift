//
//  QuoteZipCodeEntryCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol QuoteZipCodeEntryCellDelegate: class {
	func didPressLocate()
	func didUpdate(zipCode: String?)
}

class QuoteZipCodeEntryCell: BaseTableViewCell {

	@IBOutlet weak var locateButton: UIButton!
	@IBOutlet weak var zipCodeTextField: UITextField!
	
	public weak var delegate: QuoteZipCodeEntryCellDelegate?
	
	override func awakeFromNib() {
        super.awakeFromNib()
		locateButton.tintColor = .tgGreen
		zipCodeTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
		zipCodeTextField.delegate = self
    }
	
	@IBAction func didPressLocateButton(_ sender: Any) {
		delegate?.didPressLocate()
	}
	
	@objc func textChanged() {
		delegate?.didUpdate(zipCode: zipCodeTextField.text)
	}
	
}

extension QuoteZipCodeEntryCell: UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if zipCodeTextField.text!.count >= 5 && string.count > 0 {
			return false
		}
		return true
	}
	
}
