//
//  FNOLPersonTemporary.swift
//  The General
//
//  Created by Trevor Alyn on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public struct FNOLPersonTemporary {
	
	var addressDetail1: String?
	var addressDetail2: String?
	var city: String?
	var country: String? = "USA"
	var firstName: String?
	var injured: String? = Injured.no.rawValue
	var injuryDetails: String?
	var injuryType: String?
	var insurancePolicyEffectiveDate: Date?
	var insurancePolicyNumber: String?
	var insuredVehicleVin: String?
	var isDriver: Bool?
	var isFromQuestionnaire = false
	var isOther: Bool?
	var isOwner: Bool?
	var isPassenger: Bool?
	var isWitness: String? = IsWitness.no.rawValue
	var lastName: String?
	var phoneNumber: String?
	var state: String?
	var transportedFromScene: String? = TransportedFromScene.dontKnow.rawValue
	var zip: String?
	
	public func valueFor(responseKey: String) -> Any? {
		if let suffix = responseKey.components(separatedBy: ".").last {
			switch suffix {
			case "firstName":
				return self.firstName
			case "lastName":
				return self.lastName
			case "phoneNumber":
				return self.phoneNumber
			case "street":
				return self.addressDetail1
			case "addressDetail1":
				return self.addressDetail2
			case "city":
				return self.city
			case "state":
				return self.state
			case "zip":
				return self.zip
			case "country":
				return self.country
			case "injured":
				return self.injured
			case "injuryType":
				return self.injuryType
			case "transportedFromScene":
				return self.transportedFromScene
			case "injuryDescription":
				return self.injuryDetails
			case "isThisPersonWitness":
				return self.isWitness
			case "policyNumber":
				return self.insurancePolicyNumber
			case "effectiveDates":
				return self.insurancePolicyEffectiveDate
			case "VIN":
				return self.insuredVehicleVin
			default:
				return nil
			}
		}
		return nil
	}
	
	public mutating func update(value: Any?, forResponseKey responseKey: String) {
		if let suffix = responseKey.components(separatedBy: ".").last {
			switch suffix {
			case "firstName":
				self.firstName = value as? String
			case "lastName":
				self.lastName = value as? String
			case "phoneNumber":
				self.phoneNumber = value as? String
			case "street":
				self.addressDetail1 = value as? String
			case "addressDetail1":
				self.addressDetail2 = value as? String
			case "city":
				self.city = value as? String
			case "state":
				self.state = value as? String
			case "zip":
				self.zip = value as? String
			case "country":
				self.country = value as? String
			case "injured":
				self.injured = value as? String
			case "injuryType":
				self.injuryType = value as? String
			case "transportedFromScene":
				self.transportedFromScene = value as? String
			case "injuryDescription":
				self.injuryDetails = value as? String
			case "isThisPersonWitness":
				self.isWitness = value as? String
			case "policyNumber":
				self.insurancePolicyNumber = value as? String
			case "effectiveDates":
				self.insurancePolicyEffectiveDate = value as? Date
			case "VIN":
				self.insuredVehicleVin = value as? String
			default:
				break
			}
		}
	}

}
