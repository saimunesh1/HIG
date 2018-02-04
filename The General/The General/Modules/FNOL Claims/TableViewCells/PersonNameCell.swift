//
//  PassengerCell.swift
//  The General
//
//  Created by Trevor Alyn on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PersonNameCell: BaseTableViewCell {
	
	@IBOutlet weak var personNameLabel: UILabel!
	
	public var fnolPerson: FNOLPerson? {
		didSet {
			guard let person = fnolPerson else {
				return
			}
			personNameLabel.text = "\(person.firstName ?? "") \(person.lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines).initialCapped
		}
	}
	
}
