//
//  FNOLPerson+CoreDataClass.swift
//  The General
//
//  Created by Trevor Alyn on 11/6/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import UIKit
import CoreData
import MagicalRecord

public enum Injured: String {
	case yes = "Yes"
	case no = "No"
	case unsure = "Unsure"
	static let allValues = [yes.rawValue, no.rawValue, unsure.rawValue]
}

public enum TransportedFromScene: String {
	case yes = "Yes"
	case no = "No"
	case dontKnow = "I don't know"
	static let allValues = [yes.rawValue, no.rawValue, dontKnow.rawValue]
}

public enum IsWitness: String {
	case yes = "Yes"
	case no = "No"
	static let allValues = [yes.rawValue, no.rawValue]
}

public enum InjuryType: String {
	case minor = "Minor"
	case moderate = "Moderate"
	case major = "Major"
	case lifeThreatening = "Life-threatening"
	case death = "Death"
	static let allValues = [minor.rawValue, moderate.rawValue, major.rawValue, lifeThreatening.rawValue, death.rawValue]
}

@objc(FNOLPerson)
public class FNOLPerson: NSManagedObject {
	
	private let insuranceDateFormatter = DateFormatter.insuranceEffectiveDate
	
	public func populateFrom(driverInfo: DriverInfo) {
		addressDetail1 = driverInfo.addressDetail1
		addressDetail2 = driverInfo.addressDetail2
		city = driverInfo.city
		country = driverInfo.country
		firstName = driverInfo.firstName
		lastName = driverInfo.lastName
		phoneNumber = driverInfo.phoneNumber
		state = driverInfo.state
		zip = driverInfo.zip
		isFromQuestionnaire = true
	}
	
	/// Creates a temporary FNOLPerson for editing.
	///
	public func temporaryCopy() -> FNOLPersonTemporary {
		var temp = FNOLPersonTemporary()
		temp.addressDetail1 = addressDetail1
		temp.addressDetail2 = addressDetail2
		temp.city = city
		temp.country = country
		temp.firstName = firstName
		temp.injured = injured
		temp.injuryDetails = injuryDetails
		temp.injuryType = injuryType
		temp.insurancePolicyEffectiveDate = insurancePolicyEffectiveDate
		temp.insurancePolicyNumber = insurancePolicyNumber
		temp.insuredVehicleVin = insuredVehicleVin
		temp.isDriver = isDriver
		temp.isFromQuestionnaire = isFromQuestionnaire
		temp.isOther = isOther
		temp.isOwner = isOwner
		temp.isWitness = isWitness
		temp.isPassenger = isPassenger
		temp.lastName = lastName
		temp.phoneNumber = phoneNumber
		temp.state = state
		temp.transportedFromScene = transportedFromScene
		temp.zip = zip
		return temp
	}
	
	/// Populates the entity from a temporary FNOLPerson.
	///
	/// - Parameters:
	///   - temp: FNOLPersonTemporary
	public func updateFromTemporaryCopy(temp: FNOLPersonTemporary) {
        self.addressDetail1 = temp.addressDetail1
        self.addressDetail2 = temp.addressDetail2
        self.city = temp.city
        self.country = temp.country
        self.firstName = temp.firstName
        self.injured = temp.injured
        self.injuryDetails = temp.injuryDetails
        self.injuryType = temp.injuryType
        self.insurancePolicyEffectiveDate = temp.insurancePolicyEffectiveDate
        self.insurancePolicyNumber = temp.insurancePolicyNumber
        self.insuredVehicleVin = temp.insuredVehicleVin
        if let isDriver = temp.isDriver {
            self.isDriver = isDriver
        }
        self.isFromQuestionnaire = temp.isFromQuestionnaire
        if let isOther = temp.isOther {
            self.isOther = isOther
        }
        if let isOwner = temp.isOwner {
            self.isOwner = isOwner
        }
        if let isPassenger = temp.isPassenger {
            self.isPassenger = isPassenger
        }
        if let isWitness = temp.isWitness {
            self.isWitness = isWitness
        }
        self.lastName = temp.lastName
        self.phoneNumber = temp.phoneNumber
        self.state = temp.state
        self.transportedFromScene = temp.transportedFromScene
        self.zip = temp.zip
	}
	
}

// MARK: - Exporting as JSON
extension FNOLPerson {
	
	func asDictionary() -> [String: Any] {
		var personDict = [String: Any]()
		if let firstName = self.firstName { personDict["firstName"] = firstName }
		if let lastName = self.lastName { personDict["lastName"] = lastName }
		if let addressDetail1 = self.addressDetail1 { personDict["addressDetail1"] = addressDetail1 }
		if let addressDetail2 = self.addressDetail2 { personDict["addressDetail2"] = addressDetail2 }
		if let city = self.city { personDict["city"] = city }
		if let state = self.state { personDict["state"] = state }
		if let zip = self.zip { personDict["zip"] = zip }
		if let injured = self.injured { personDict["injured"] = injured }
		if let injuryDescription = self.injuryDetails { personDict["injuryDescription"] = injuryDescription }
		if let injuryType = self.injuryType { personDict["injuryType"] = injuryType }
		if let phoneNumber = self.phoneNumber { personDict["phoneNumber"] = phoneNumber }
		if let transportedFromScene = self.transportedFromScene { personDict["transportedFromScene"] = transportedFromScene }
		if let licenseImage = self.licenseImage { personDict["pictureIds"] = [licenseImage.imageId] }
		
		// Insurance info
		var insuranceDict = [String: Any]()
		if let insurancePolicyEffectiveDate = self.insurancePolicyEffectiveDate { insuranceDict["effectiveDates"] = insuranceDateFormatter.string(from: insurancePolicyEffectiveDate) }
		if let insurancePolicyNumber = self.insurancePolicyNumber { insuranceDict["policyNumber"] = insurancePolicyNumber }
		if let insuredVehicleVin = self.insuredVehicleVin { insuranceDict["vin"] = insuredVehicleVin }
		if let insuranceImage = self.insuranceImage { insuranceDict["pictureIds"] = [insuranceImage.imageId] }
		personDict["insurance"] = insuranceDict
		
		return personDict
	}

}

// MARK: - Images
extension FNOLPerson {
	
	/// Add image associated with a PersonPhotoType.
	///
	/// - Parameters:
	///   - image: Image
	///   - imageType: PersonPhotoType
	func addImage(_ image: UIImage, imageType: PersonPhotoType) {
        let moImage = FNOLImage.mr_createEntity()!
        moImage.generateImageIdIfNeeded()
        moImage.imageData = UIImagePNGRepresentation(image)
				
        if imageType == .license {
            self.licenseImage = moImage
        }
        else if imageType == .insurance {
            self.insuranceImage = moImage
        }
	}
	
	/// Creates or updates the first image object found matching the PersonPhotoType.
	///
	/// - Parameters:
	///   - image: Image
	///   - imageType: PersonPhotoType
	func setImage(_ image: UIImage, imageType: PersonPhotoType) {
		// Get first image object associated with claim/type
        // TODO: ^^^ Should we actually be doing that?
		var moImage: FNOLImage?
        
		if imageType == .license {
			moImage = self.licenseImage
		} else if imageType == .insurance {
			moImage = self.insuranceImage
		}
		
		if let moImage = moImage {
			moImage.imageData = UIImagePNGRepresentation(image)
		}
		else { // Not found, create a new one.
            self.addImage(image, imageType: imageType)
		}
	}
	
}
