//
//  PeopleDriverCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PeopleDriverCell: BaseTableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
	@IBOutlet var errorLabel: UILabel!

	public var attributedText: NSAttributedString? {
		didSet {
			if self.person == nil {
				titleLabel.attributedText = attributedText
			}
		}
	}
	public var item: Field?
	public var person: FNOLPerson? { didSet { setPerson(person: person) } }

	override func awakeFromNib() {
		super.awakeFromNib()
		var imageView: UIImageView
		imageView  = UIImageView(frame:CGRect(x:10, y:5, width:10, height:10))
		imageView.image = #imageLiteral(resourceName: "arrow")
		self.accessoryView = imageView
		clipsToBounds = true
	}
	
	private func setPerson(person: FNOLPerson?) {
		guard let value = person else {
			return
		}
		titleLabel.text = NSLocalizedString("driverinfo.driver", comment: "Driver")
		if let firstName = value.firstName, let lastName = value.lastName {
			valueLabel.text = "\(firstName.capitalized) \(lastName.capitalized)"
		} else if let lastName = value.lastName {
			valueLabel.text = lastName
		} else if let firstName = value.firstName {
			valueLabel.text = firstName
		} else {
			valueLabel.text = ""
		}
	}
	
}
