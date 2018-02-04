//
//  DisclosureCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol DisclosureCellDelegate {
	func didUpdate(text: String, forResponseKey responseKey: String)
}

class DisclosureCell: BaseTableViewCell {
    
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var promptLabel: UILabel!
    @IBOutlet var valueField: UITextField!
    @IBOutlet var errorLabel: UILabel!

	var delegate: DisclosureCellDelegate?
    
    var field: Field? {
        didSet {
            guard let value = field else { return }
            titleLabel.text = value.label
			valueField.text = value.defaultValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        var imageView: UIImageView
        imageView  = UIImageView(frame:CGRect(x:10, y:5, width:10, height:10))
        imageView.image = #imageLiteral(resourceName: "arrow")
        self.accessoryView = imageView
        valueField.delegate = self
		promptLabel.textColor = .tgTextFontColor
      }
    
    func fetchSavedClaimValues() {
        
        // We dont know whether which value picked and saved to Cliam , So need to look for both
        // TODO: Decide subtype and then main Type
        if field?.responseKey == "accidentDetails.whatHappened.type" || field?.responseKey == "accidentDetails.whatHappened.subType" {
            let type = ApplicationContext.shared.fnolClaimsManager.activeClaim?.displayValue(forResponseKey: "accidentDetails.whatHappened.type")
            
            let subTypeValue = ApplicationContext.shared.fnolClaimsManager.activeClaim?.displayValue(forResponseKey: "accidentDetails.whatHappened.subType")
            
            if subTypeValue?.isEmpty ?? true {
                if type?.isEmpty ?? true {
                    self.valueField.text = field?.placeHolder
                }else{
                    self.valueField.text = type
                }
            }else{
                self.valueField.text = subTypeValue
            }
            
        }else{
            if let value = ApplicationContext.shared.fnolClaimsManager.activeClaim?.displayValue(forResponseKey:(field?.responseKey)!) {
                self.valueField.text = value
            }else{
                self.valueField.text = field?.placeHolder
            }
        }
	}
}

extension DisclosureCell: UITextFieldDelegate {
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if let responseKey = field?.responseKey, let text = textField.text {
			delegate?.didUpdate(text: text, forResponseKey: responseKey)
		}
	}
	
}
