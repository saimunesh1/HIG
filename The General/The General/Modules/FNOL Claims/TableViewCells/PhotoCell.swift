//
//  PictureTableViewCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PhotoCell: BaseTableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueField: UITextField!
    @IBOutlet var errorLabel: UILabel!

    var field: Field? {
        didSet {
            guard let vlaue = field else { return }
            self.titleLabel?.text = vlaue.label
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var imageView: UIImageView
        imageView  = UIImageView(frame:CGRect(x:10, y:5, width:10, height:10))
        imageView.image = #imageLiteral(resourceName: "arrow")
        accessoryView = imageView
		valueField.textColor = .tgTextFontColor
    }
    
    func fetchSavedvalues() {
		if let activeClaim = ApplicationContext.shared.fnolClaimsManager.activeClaim, let images = activeClaim.images {
			if images.count > 0 {
				self.valueField.text = "\(images.count) \(NSLocalizedString(images.count > 1 ? "label.photos" : "label.photo", comment: ""))"
				return
			}
			self.valueField.placeholder = self.field?.placeHolder
			self.valueField.text = ""
		}
    }
    
    func checkForRequired() {
        if (self.field?.required)! {
            self.titleLabel.attributedText = Helper.requiredAttributedText(text:(self.field?.label!)!)
        } else {
            self.titleLabel.text = self.field?.label
        }
    }
	
}
