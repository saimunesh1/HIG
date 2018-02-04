//
//  FNOLVehicle+CoreDataClass.swift
//  The General
//
//  Created by Trevor Alyn on 11/6/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import CoreData
import MagicalRecord

public enum VehicleImageType {
	case licensePlate
	case vinNumber
}

@objc(FNOLVehicle)
public class FNOLVehicle: NSManagedObject {

	public func populateFrom(vehicleInfo: VehicleInfo) {
		licensePlate = vehicleInfo.licensePlate
		make = vehicleInfo.make
		model = vehicleInfo.model
		riskUnit = vehicleInfo.riskUnit
		vin = vehicleInfo.vin
		year = vehicleInfo.year
        indexInClaim = 0
	}
	
	/// Creates a temporary FNOLVehicle for editing.
	///
	public func temporaryCopy() -> FNOLVehicleTemporary {
		var temp = FNOLVehicleTemporary()
		temp.colour = colour
		temp.driver = driver
		temp.damageSeverity = damageSeverity
		temp.indexInClaim = indexInClaim
		temp.licensePlate = licensePlate
		temp.make = make
		temp.model = model
		temp.owner = owner
		temp.riskUnit = riskUnit
		temp.vin = vin
		temp.year = year
		return temp
	}
	
	/// Populates the entity from a temporary FNOLVehicle.
	///
	/// - Parameters:
	///   - temp: FNOLVehicleTemporary
	public func updateFromTemporaryCopy(temp: FNOLVehicleTemporary) {
        self.colour = temp.colour
		self.damageSeverity = temp.damageSeverity
		self.driver = temp.driver
        self.indexInClaim = temp.indexInClaim
        self.licensePlate = temp.licensePlate
        self.make = temp.make
        self.model = temp.model
        self.owner = temp.owner
        self.riskUnit = temp.riskUnit
        self.vin = temp.vin
        self.year = temp.year
	}

}

// MARK: - Exporting as JSON
extension FNOLVehicle {
	
	func asDictionary() -> [String: Any] {
		var vehicleJson = [String: Any]()
		
		// Vehicle info
		var vehicleInfoDict = [String: Any]()
		vehicleInfoDict["doesntHaveVehicleInfo"] = self.year == nil
		if let colour = self.colour { vehicleInfoDict["color"	] = colour }
		if let licensePlate = self.licensePlate { vehicleInfoDict["licensePlate"] = licensePlate }
		if let licensePlateImageId = self.licensePlateImage?.imageId { vehicleInfoDict["pictureIds"] = [licensePlateImageId] }
		if let year = self.year { vehicleInfoDict["year"] = year }
		if let make = self.make { vehicleInfoDict["make"] = make }
		if let model = self.model { vehicleInfoDict["model"] = model }
		if let severity = self.damageSeverity { vehicleInfoDict["severity"] = severity }
		if let vin = self.vin { vehicleInfoDict["vin"] = vin }
		vehicleJson["vehicleInfo"] = vehicleInfoDict
		
		// People
		if let people = self.people?.allObjects as? [FNOLPerson] {
			
			// Owner
			if let owner = people.first(where: { $0.vehicle == self && $0.isOwner == true }) {
				vehicleJson["ownerContact"] = owner.asDictionary()
			}
			
			// Driver
			if let driver = people.first(where: { $0.vehicle == self && $0.isDriver == true }) {
				vehicleJson["driver"] = driver.asDictionary()
			}
			
			// Passengers
			let passengers = people.filter({ $0.vehicle == self && $0.isPassenger == true })
			if passengers.count > 0 {
				var passengersDict = [Any]()
				passengers.forEach({ (passenger) in
					let passengerDict = passenger.asDictionary()
					passengersDict.append(passengerDict)
				})
				vehicleJson["passengers"] = passengersDict
			}
		}
		return vehicleJson
	}
	
}

// MARK: - Images
extension FNOLVehicle {
	
	/// Add an image associated with a VehicleImageType.
	///
	/// - Parameters:
	///   - image: Image
	///   - imageType: VehicleImageType key
	func addImage(_ image: UIImage, imageType: VehicleImageType) {
		let moImage: FNOLImage = FNOLImage.mr_createEntity()!
		moImage.claim = ApplicationContext.shared.fnolClaimsManager.activeClaim
		moImage.generateImageIdIfNeeded()
		moImage.image = image
		switch imageType {
		case .licensePlate:
			self.licensePlateImage = moImage
		case .vinNumber:
			self.vinNumberImage = moImage
		}
	}
	
	/// Creates or updates image object of the indicated type.
	///
	/// - Parameters:
	///   - image: Image
	///   - imageType: VehicleImageType
	func setImage(_ image: UIImage, imageType: VehicleImageType) {
		switch imageType {
		case .licensePlate:
			if let moImage = self.licensePlateImage {
				moImage.image = image
			} else {
				self.addImage(image, imageType: imageType)
			}
		case .vinNumber:
			if let moImage = self.vinNumberImage {
				moImage.image = image
			} else {
				self.addImage(image, imageType: imageType)
			}
		}
	}
	
}
