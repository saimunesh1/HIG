//
//  CityCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/10/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AddressFieldCell: BaseTableViewCell, UITextFieldDelegate {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    var field: Field? {
        didSet {
            guard let value = field else { return }
            self.titleLabel?.text = value.label
            self.valueField.placeholder = value.placeHolder
        }
    }
    
    var responseKey: String {
        get {
            return self.field?.responseKey ?? ""
        }
    }
    var onValueChanged = { (_: AddressFieldCell) in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.valueField.delegate = self
        self.valueField.addTarget(self, action: #selector(textFieldDidChange(textField: )), for: .editingChanged)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        self.onValueChanged(self)

    }

}
