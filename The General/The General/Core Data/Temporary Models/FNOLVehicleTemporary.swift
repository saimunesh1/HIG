//
//  FNOLVehicleTemporary.swift
//  The General
//
//  Created by Trevor Alyn on 11/14/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public struct FNOLVehicleTemporary {

	var colour: String?
	var damageSeverity: String?
	var driver: FNOLPerson?
    var indexInClaim: Int32 = 0
	var licensePlate: String?
	var make: String?
	var model: String?
	var owner: FNOLPerson?
	var riskUnit: String?
	var vin: String?
	var year: String?
	
	public func valueFor(responseKey: String) -> Any? {
		if let suffix = responseKey.components(separatedBy: ".").last {
			switch suffix {
			case "colour":
				return self.colour
			case "damageSeverity":
				return self.damageSeverity
			case "indexInClaim":
				return self.indexInClaim
			case "licensePlate":
				return self.licensePlate
			case "make":
				return self.make
			case "model":
				return self.model
			case "riskUnit":
				return self.riskUnit
			case "vin":
				return self.vin
			case "year":
				return self.year
			default:
				return nil
			}
		}
		return nil
	}
	
	public mutating func update(value: Any?, forResponseKey responseKey: String) {
		if let suffix = responseKey.components(separatedBy: ".").last {
			switch suffix {
			case "colour":
				self.colour = value as? String
			case "damageSeverity":
				self.damageSeverity = value as? String
			case "indexInClaim":
				self.indexInClaim = value as! Int32
			case "licensePlate":
				self.licensePlate = value as? String
			case "make":
				self.make = value as? String
			case "model":
				self.model = value as? String
			case "riskUnit":
				self.riskUnit = value as? String
			case "vin":
				self.vin = value as? String
			case "year":
				self.year = value as? String
			default:
				break
			}
		}
	}

}
