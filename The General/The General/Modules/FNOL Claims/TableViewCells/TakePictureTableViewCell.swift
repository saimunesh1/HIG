//
//  TakePictureTableViewCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/31/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class TakePictureTableViewCell: BaseTableViewCell {

    @IBOutlet var valueField: UITextField!
    @IBOutlet var pictureView: UIView!

	var textFieldCallback: ((String) -> ())?
    var delegate: CollapsibleTableViewHeaderDelegate?
    var field: Field?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer: )))
        gestureRecognizer.delegate = self
        pictureView.addGestureRecognizer(gestureRecognizer)
        valueField.delegate = self
    }

    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
		self.delegate?.didTapOnTakePicture(isSelected: true, field: field)
    }
    
}

extension TakePictureTableViewCell: UITextFieldDelegate {
    
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
