//
//  VINNumberCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class VINNumberCell: UITableViewCell {

    var callback: ((String) -> ())?

    @IBOutlet var vinTitleLabel: UILabel!
    @IBOutlet var vinField: UITextField!
    var item: Field?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        vinField.delegate = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}

extension VINNumberCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.callback?(textField.text ?? "")
    }
}
