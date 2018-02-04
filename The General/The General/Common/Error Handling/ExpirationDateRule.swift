//
//  ExpirationDateRule.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 2/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class ExpirationDateRule: FieldRule {
	
	func validate(_ value: String) -> Bool {
		let test = NSPredicate(format: "SELF MATCHES %@", "^(0?[1-9]|1[0-2])/?([0-9]{4}|[0-9]{2})$")
		if test.evaluate(with: value) == true {
			let numbers = value.components(separatedBy: "/")
			let month = Int(numbers[0])
			let year = Int("20" + numbers[1])
			let todayDateComponents = Calendar.current.dateComponents([.month, .year], from: Date())
			if let month = month, let year = year, let todayMonth = todayDateComponents.month, let todayYear = todayDateComponents.year {
				return year > todayYear || (year >= todayYear && month >= todayMonth)
			}
		}
		return false
	}
	
	func errorMessage() -> String {
		return NSLocalizedString("error.expirationdate", comment: "Expiration date must be MM/DD and in the future.")
	}
	
}
