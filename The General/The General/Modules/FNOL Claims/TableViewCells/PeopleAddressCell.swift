//
//  PeopleAddressCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/16/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PeopleAddressCell: BaseTableViewCell {
	
	@IBOutlet weak var addressField: UILabel!

	public var item: Field?
	public var person: FNOLPerson? { didSet { setPerson(person: person) } }

	private func setPerson(person: FNOLPerson?) {
		guard let person = person else {
			return
		}
		let address1 = person.addressDetail1?.capitalized ?? ""
		let address2 = person.addressDetail2?.capitalized ?? ""
		var addressLine1 = address1
		if !address2.isEmpty {
			addressLine1 += ", \(address2)"
		}
		let city = person.city?.capitalized ?? ""
		let state = person.state ?? ""
		let zip = person.zip ?? ""
		var addressLine2 = ""
		if !city.isEmpty {
			addressLine2 += city
		}
		if !state.isEmpty {
			if addressLine2.isEmpty {
				addressLine2 += state
			} else {
				addressLine2 += ", \(state)"
			}
		}
		if !zip.isEmpty {
			if addressLine2.isEmpty {
				addressLine2 += zip
			} else {
				addressLine2 += " \(zip)"
			}
		}
		self.addressField.text = "\(addressLine1)\n\(addressLine2)"
	}

}
