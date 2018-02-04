//
//  DetailTableViewCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol DetailTableViewCellDelegate {
	func didFinishEditing(value: String, cell: DetailTableViewCell)
}

class DetailTableViewCell: BaseTableViewCell {

    @IBOutlet var textView: UITextView!
	
	var delegate: DetailTableViewCellDelegate?
	
	var field: Field? {
		didSet {
			if let placeholder = field?.placeHolder, !placeholder.isEmpty {
				textView.text = placeholder
			} else {
				textView.text = field?.label
			}
		}
	}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
		textView.delegate = self
    }
    
    func fetchValues() {
        if ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: (field?.responseKey!)!) != nil {
            self.textView.text = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: (field?.responseKey!)!)
            textView.textColor = UIColor.black
        }else{
            textView.textColor = UIColor.lightGray
        }
    }
	
}

extension DetailTableViewCell: UITextViewDelegate {
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.lightGray {
			textView.text = nil
			textView.textColor = UIColor.black
		}
	}

    func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = field?.placeHolder
			textView.textColor = UIColor.lightGray
		}
		delegate?.didFinishEditing(value: textView.text, cell: self)
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			textView.resignFirstResponder()
			return false
		}
		let newText = (textView.text as NSString?)?.replacingCharacters(in: range, with: text) ?? text
		return newText.count <= 255;
	}

	func textViewShouldReturn(_ textView: UITextField) -> Bool {
		textView.resignFirstResponder()
		return true
	}

}
