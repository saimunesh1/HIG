//
//  ClaimsMyVehicleDetailsVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsMyVehicleDetailsVC: ClaimsDetailsBaseVC {
	
	public var vehicle: Vehicle! { didSet { setUpFromVehicle() } }

	func setUpFromVehicle() {
		infoCellModels = [InfoCellModel]()
		
		// Vehicle description
		let vehicleDescriptionString = vehicleDescriptionStringFrom(vehicle: vehicle)
		if !vehicleDescriptionString.isEmpty {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claimreview.myvehicle", comment: "My vehicle"), value: vehicleDescriptionString, multiline: false, isHeading: false, tapResult: nil))
		}

		// Damaged parts
		if let damagedParts = vehicle.damagedParts {
			var damagedPartsString = ""
			if let _ = damagedParts.driverFender { damagedPartsString += "\(NSLocalizedString("damagedParts.driverFender", comment: ""))\n" }
			if let _ = damagedParts.driverFrontDoor { damagedPartsString += "\(NSLocalizedString("damagedParts.driverFrontDoor", comment: ""))\n" }
			if let _ = damagedParts.driverFrontWheel { damagedPartsString += "\(NSLocalizedString("damagedParts.driverFrontWheel", comment: ""))\n" }
			if let _ = damagedParts.driverQuarterPanel { damagedPartsString += "\(NSLocalizedString("damagedParts.driverQuarterPanel", comment: ""))\n" }
			if let _ = damagedParts.driverReadDoor { damagedPartsString += "\(NSLocalizedString("damagedParts.driverReadDoor", comment: ""))\n" }
			if let _ = damagedParts.driverRearWheel { damagedPartsString += "\(NSLocalizedString("damagedParts.driverRearWheel", comment: ""))\n" }
			if let _ = damagedParts.frontBumper { damagedPartsString += "\(NSLocalizedString("damagedParts.frontBumper", comment: ""))\n" }
			if let _ = damagedParts.hood { damagedPartsString += "\(NSLocalizedString("damagedParts.hood", comment: ""))\n" }
			if let _ = damagedParts.passengerFender { damagedPartsString += "\(NSLocalizedString("damagedParts.passengerFender", comment: ""))\n" }
			if let _ = damagedParts.passengerFrontDoor { damagedPartsString += "\(NSLocalizedString("damagedParts.passengerFrontDoor", comment: ""))\n" }
			if let _ = damagedParts.passengerFrontWheel { damagedPartsString += "\(NSLocalizedString("damagedParts.passengerFrontWheel", comment: ""))\n" }
			if let _ = damagedParts.passengerQuarterPanel { damagedPartsString += "\(NSLocalizedString("damagedParts.passengerQuarterPanel", comment: ""))\n" }
			if let _ = damagedParts.passengerRearDoor { damagedPartsString += "\(NSLocalizedString("damagedParts.passengerRearDoor", comment: ""))\n" }
			if let _ = damagedParts.passengerRearWheel { damagedPartsString += "\(NSLocalizedString("damagedParts.passengerRearWheel", comment: ""))\n" }
			if let _ = damagedParts.rearBumper { damagedPartsString += "\(NSLocalizedString("damagedParts.rearBumper", comment: ""))\n" }
			if let _ = damagedParts.roof { damagedPartsString += "\(NSLocalizedString("damagedParts.roof", comment: ""))\n" }
			if let _ = damagedParts.trunk { damagedPartsString += "\(NSLocalizedString("damagedParts.trunk", comment: ""))\n" }
			if let _ = damagedParts.windShield { damagedPartsString += "\(NSLocalizedString("damagedParts.windShield", comment: ""))\n" }

			if damagedPartsString.count > 0 {

				// Remove last line (just a return)
				damagedPartsString = String(damagedPartsString.dropLast())
				infoCellModels.append(InfoCellModel(property: "Damaged parts", value: damagedPartsString, multiline: false, isHeading: false, tapResult: nil))
			}
		}

		// Damage details

		if let airbagsDeployed = vehicle.damageDetails?.airbagsDeployed {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.airbagsDeployed", comment: ""), value: airbagsDeployed, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let airbagsStolen = vehicle.damageDetails?.airbagsStolen {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.airbagsStolen", comment: ""), value: airbagsStolen, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let dentSizeOfBaseball = vehicle.damageDetails?.dentSizeOfBaseball {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.dentSizeOfBaseball", comment: ""), value: dentSizeOfBaseball, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let deviceToFreeOccupants = vehicle.damageDetails?.deviceToFreeOccupants {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.deviceToFreeOccupants", comment: ""), value: deviceToFreeOccupants, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let doorsOperable = vehicle.damageDetails?.doorsOperable {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.doorsOperable", comment: ""), value: doorsOperable, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let engineStarts = vehicle.damageDetails?.engineStarts {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.engineStarts", comment: ""), value: engineStarts, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let engineSubmerged = vehicle.damageDetails?.engineSubmerged {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.engineSubmerged", comment: ""), value: engineSubmerged, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let fireBurnDash = vehicle.damageDetails?.fireBurnDash {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.fireBurnDash", comment: ""), value: fireBurnDash, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let fireBurnEngine = vehicle.damageDetails?.fireBurnEngine {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.fireBurnEngine", comment: ""), value: fireBurnEngine, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let fireBurnFrontHalfOfVehicle = vehicle.damageDetails?.fireBurnFrontHalfOfVehicle {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.fireBurnFrontHalfOfVehicle", comment: ""), value: fireBurnFrontHalfOfVehicle, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let fireBurnFrontHalfOfVehicle = vehicle.damageDetails?.fireBurnRearHalfVehicle {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.fireBurnRearHalfVehicle", comment: ""), value: fireBurnFrontHalfOfVehicle, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let fireBurnSeats = vehicle.damageDetails?.fireBurnSeats {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.fireBurnSeats", comment: ""), value: fireBurnSeats, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let fireElectrical = vehicle.damageDetails?.fireElectrical {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.fireElectrical", comment: ""), value: fireElectrical, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let floodSaltWater = vehicle.damageDetails?.floodSaltWater {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.floodSaltWater", comment: ""), value: floodSaltWater, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let fluidsLeaking = vehicle.damageDetails?.fluidsLeaking {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.fluidsLeaking", comment: ""), value: fluidsLeaking, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let glassByHail = vehicle.damageDetails?.glassByHail {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.glassByHail", comment: ""), value: glassByHail, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let hailDamageAtLeast3BodyPanels = vehicle.damageDetails?.hailDamageAtLeast3BodyPanels {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.hailDamageAtLeast3BodyPanels", comment: ""), value: hailDamageAtLeast3BodyPanels, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let interiorMissing = vehicle.damageDetails?.interiorMissing {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.interiorMissing", comment: ""), value: interiorMissing, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let seatsorDashboard = vehicle.damageDetails?.seatsorDashboard {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.seatsorDashboard", comment: ""), value: seatsorDashboard, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let theftDamageToAtLeast3BodyPanels = vehicle.damageDetails?.theftDamageToAtLeast3BodyPanels {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.theftDamageToAtLeast3BodyPanels", comment: ""), value: theftDamageToAtLeast3BodyPanels, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let waterLevelDash = vehicle.damageDetails?.waterLevelDash {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.waterLevelDash", comment: ""), value: waterLevelDash, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let waterLevelSeats = vehicle.damageDetails?.waterLevelSeats {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.waterLevelSeats", comment: ""), value: waterLevelSeats, multiline: false, isHeading: false, tapResult: nil))
		}
		
		if let wheelsTiresStolen = vehicle.damageDetails?.wheelsTiresStolen {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.wheelsTiresStolen", comment: ""), value: wheelsTiresStolen, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Driveable?
		if let drivable = vehicle.drivable {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.drivable", comment: "Can the vehicle be safely driven?"), value: drivable.yesNoString, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Suspension or frame
		if let suspensionOrFrame = vehicle.suspensionOrFrame {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("damageDetails.suspensionOrFrame", comment: ""), value: "\(suspensionOrFrame)", multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Can we move it?
		if let permissionToMove = vehicle.permissionToMove {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.permissiontomove", comment: "Can we move your vehicle?"), value: permissionToMove.yesNoString, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// When can we move it?
		if let dateAvailableToMove = vehicle.dateAvailableToMove {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.dateavailabletomove", comment: "When can we move it?"), value: dateAvailableToMove, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Vehicle location address
		let addressString = addressStringFromFields(address1: vehicle.vehicleLocationAddress1, address2: vehicle.vehicleLocationAddress2, address3: vehicle.vehicleLocationAddress3, city: vehicle.vehicleLocationCity, state: vehicle.vehicleLocationState, zip: vehicle.vehicleLocationZip)
		if !addressString.isEmpty {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.address", comment: "Address"), value: addressString, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Owner
		if let vehicleOwner = vehicle.vehicleOwner {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.vehicleowner", comment: "Vehicle's owner"), value: vehicleOwner, multiline: false, isHeading: false, tapResult: nil))
		}
		
		addRowsForDriverAndPassengers(vehicle: vehicle)
	}
	
}
