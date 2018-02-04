//
//  LicenseTableViewCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class LicenseTableViewCell: BaseTableViewCell {

    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var deleteImage: UIImageView!
    @IBOutlet var valueTextField: UITextField!
    
	public var deletePictureCallBack: ((String) -> ())?
	public var item: Field?
	public var textFieldCallback: ((String) -> ())?

	override func awakeFromNib() {
        super.awakeFromNib()
		valueTextField.textColor = .tgTextFontColor
        valueTextField.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(tap: )))
        gestureRecognizer.delegate = self
        deleteImage.addGestureRecognizer(gestureRecognizer)
    }

    @objc func handleTap(tap: UITapGestureRecognizer) {
        deletePictureCallBack?("DeleteImage")
    }

}

extension LicenseTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.textFieldCallback!(textField.text ?? "")
	}

}
