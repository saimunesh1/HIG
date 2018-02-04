//
//  PeoplePhoneNumberCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/16/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PeoplePhoneNumberCell: BaseTableViewCell {

	@IBOutlet weak var phoneNumberField: UITextField!

	public var item: Field?
	public var person: FNOLPerson? { didSet { setPerson(person: person) } }

	override func awakeFromNib() {
		super.awakeFromNib()
		phoneNumberField.textColor = .tgTextFontColor
    }
	
	private func setPerson(person: FNOLPerson?) {
		guard let person = person else {
			return
		}
		if let phone = person.phoneNumber {
			self.phoneNumberField.text = "\(phone)"
		}
	}

}
