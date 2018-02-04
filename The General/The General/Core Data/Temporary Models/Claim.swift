//
//  Claim.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

struct Vehicle: Equatable {
	
	static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
		return lhs.make == rhs.make && lhs.model == rhs.model && lhs.year == rhs.year && lhs.licensePlate == rhs.licensePlate
	}
	
	var color: String?
	var damageDesc: String?
	var damageDetails: VehicleDamageDetails?
	var damagedParts: VehicleDamagedParts?
	var damageSeverity: String?
	var dateAvailableToMove: String?
	var drivable: Bool?
	var licensePlate: String?
	var make: String?
	var model: String?
	var permissionToMove: Bool?
	var policyVehicle: Int?
	var severityOfDamage: Int?
	var suspensionOrFrame: Int?
	var vehicleLocationAddress1: String?
	var vehicleLocationAddress2: String?
	var vehicleLocationAddress3: String?
	var vehicleLocationCity: String?
	var vehicleLocationState: String?
	var vehicleLocationZip: String?
	var vehicleOwner: String?
	var vehiclePersonList: [VehiclePerson]?
	var year: String?
}

struct VehicleDamageDetails {
	var airbagsDeployed: String?
	var airbagsStolen: String?
	var dentSizeOfBaseball: String?
	var deviceToFreeOccupants: String?
	var doorsOperable: String?
	var engineStarts: String?
	var engineSubmerged: String?
	var fireBurnDash: String?
	var fireBurnEngine: String?
	var fireBurnFrontHalfOfVehicle: String?
	var fireBurnRearHalfVehicle: String?
	var fireBurnSeats: String?
	var fireElectrical: String?
	var floodSaltWater: String?
	var fluidsLeaking: String?
	var glassByHail: String?
	var hailDamageAtLeast3BodyPanels: String?
	var interiorMissing: String?
	var seatsorDashboard: String?
	var theftDamageToAtLeast3BodyPanels: String?
	var waterLevelDash: String?
	var waterLevelSeats: String?
	var wheelsTiresStolen: String?
}

// Using Any because we don't care what the value is.
// If a value is returned, that part is considered damaged.
struct VehicleDamagedParts {
	var driverFender: Any?
	var driverFrontDoor: Any?
	var driverFrontWheel: Any?
	var driverQuarterPanel: Any?
	var driverReadDoor: Any?
	var driverRearWheel: Any?
	var frontBumper: Any?
	var hood: Any?
	var passengerFender: Any?
	var passengerFrontDoor: Any?
	var passengerFrontWheel: Any?
	var passengerQuarterPanel: Any?
	var passengerRearDoor: Any?
	var passengerRearWheel: Any?
	var rearBumper: Any?
	var roof: Any?
	var trunk: Any?
	var windShield: Any?
}

struct VehiclePerson {
	let address1: String?
	let address2: String?
	let address3: String?
	let city: String?
	let injured: String?
	let injuryDetails: String?
	let injuryType: String?
	let name: String?
	let phoneNumber: String?
	let postalCode: String?
	let state: String?
	let transportedFromScene: String?
	let type: String?
	
	init(claimVehiclePerson: ClaimVehiclePerson) {
		self.address1 = claimVehiclePerson.address1
		self.address2 = claimVehiclePerson.address2
		self.address3 = claimVehiclePerson.address3
		self.city = claimVehiclePerson.city
		self.injured = claimVehiclePerson.injured
		self.injuryDetails = claimVehiclePerson.injuryDetails
		self.injuryType = claimVehiclePerson.injuryType
		self.name = claimVehiclePerson.name
		self.phoneNumber = claimVehiclePerson.phoneNumber
		self.postalCode = claimVehiclePerson.postalCode
		self.state = claimVehiclePerson.state
		self.transportedFromScene = claimVehiclePerson.transportedFromScene
		self.type = claimVehiclePerson.type
	}
	
	init(address1: String?, address2: String?, address3: String?, city: String?, injured: String?, injuryType: String?, injuryDetails: String?, name: String?, phoneNumber: String?, postalCode: String?, state: String?, transportedFromScene: String?, type: String?) {
		self.address1 = address1
		self.address2 = address2
		self.address3 = address3
		self.city = city
		self.injured = injured
		self.injuryDetails = injuryDetails
		self.injuryType = injuryType
		self.name = name
		self.phoneNumber = phoneNumber
		self.postalCode = postalCode
		self.state = state
		self.transportedFromScene = transportedFromScene
		self.type = type
	}
}

struct PartyInvolved {
	var injured: String?
	var injuryDetails: String?
	var injuryType: String?
	var name: String?
	var transportedFromScene: Int?
	var type: String?
	
	init(claimPartyInvolved: ClaimPartyInvolved) {
		self.injured = claimPartyInvolved.injured
		self.injuryDetails = claimPartyInvolved.injuryDetails
		self.injuryType = claimPartyInvolved.injuryType
		self.name = claimPartyInvolved.name
		self.transportedFromScene = claimPartyInvolved.transportedFromScene
		self.type = claimPartyInvolved.type
	}
	
	init(name: String?, type: String?, transportedFromScene: Int?, injured: String?, injuryDetails: String?, injuryType: String?) {
		self.name = name
		self.type = type
		self.transportedFromScene = transportedFromScene
		self.injured = injured
		self.injuryDetails = injuryDetails
		self.injuryType = injuryType
	}
}

struct Claim {
	var address1: String?
	var address2: String?
	var address3: String?
	var city: String?
	var claimNumber: String?
	var claimStatus: ClaimStatus?
	var fnolClaim: FNOLClaim?
	var fnolLocalId: String?
	var lossDate: String?
	var lossDetails: String?
	var lossLocation: String?
	var lossTime: String?
	var lossType: String?
	var message: String?
	var nextStep: String?
	var nextStepDescription: String?
	var nextStepNumber: Int?
	var nextStepTitle: String?
	var partyInvolvedList: [PartyInvolved]?
	var postalCode: String?
	var state: String?
	var status: Int?
	var totalSteps: Int?
	var vehicleList = [Vehicle]()
	var year: String?
	
	/// Generate Claim from FNOLClaim for display in Claims area of app
	///
	init(fnolClaim: FNOLClaim) {
		self.fnolClaim = fnolClaim
		claimStatus = ClaimStatus(rawValue: fnolClaim.status!)
		fnolLocalId = fnolClaim.localId
		lossType = fnolClaim.displayValue(forResponseKey: "accidentDetails.whatHappened.type")
		lossLocation = fnolClaim.value(forResponseKey: "accidentDetails.locationInfo")
		lossDetails = fnolClaim.value(forResponseKey: "accidentDetails.additionalDetails")
		city = fnolClaim.value(forResponseKey: "accidentDetails.address.city")
		state = fnolClaim.value(forResponseKey: "accidentDetails.address.state")
		postalCode = fnolClaim.value(forResponseKey: "accidentDetails.address.zip")
		address1 = fnolClaim.value(forResponseKey: "accidentDetails.address.street")
		address2 = fnolClaim.value(forResponseKey: "accidentDetails.address.addressDetail1")
		address3 = fnolClaim.value(forResponseKey: "accidentDetails.address.addressDetail2")
		lossDate = fnolClaim.value(forResponseKey: "accidentDetails.dateOfAccident")
		
		// Fix format of loss time
		let inputDateFormatter = DateFormatter.hoursCivilianWithSeconds
		if let returnedTimeString = fnolClaim.value(forResponseKey: "accidentDetails.timeOfAccident"), let lossTimeAsDate = inputDateFormatter.date(from: returnedTimeString) {
			let outputDateFormatter = DateFormatter.hourMinuteMeridiemTimezone
			lossTime = outputDateFormatter.string(from: lossTimeAsDate)
		} else {
			lossTime = fnolClaim.value(forResponseKey: "accidentDetails.timeOfAccident")
		}
		
		vehicleList = [Vehicle]()
		if let fnolVehicles = fnolClaim.vehicles {
			for (_, fnolVehicle) in fnolVehicles.enumerated() {
				var vehicle = Vehicle()
				let v = fnolVehicle as! FNOLVehicle
				vehicle.make = v.make
				vehicle.model = v.model
				vehicle.color = v.colour
				vehicle.policyVehicle = v.indexInClaim == 1 ? 1 : nil // Vehicle with (indexInClaim == 1) is "My Vehicle"
				vehicle.licensePlate = v.licensePlate
//				vehicle.severityOfDamage = v.damageSeverity // TODO: Figure out what to do about this
				vehicle.year = v.year
				if v.indexInClaim == 1 { // If this is the claim reporter's vehicle
					if let drivable = fnolClaim.value(forResponseKey: "myVehicle.vehicleConditionAndLocation.canVehicleSafelyDiven") {
						vehicle.drivable = NSString(string: drivable).boolValue
					}
					if let permissionToMove = fnolClaim.value(forResponseKey: "myVehicle.vehicleConditionAndLocation.canWeMoveYourVehicle") {
						vehicle.permissionToMove = NSString(string: permissionToMove).boolValue
					}
					vehicle.dateAvailableToMove = fnolClaim.value(forResponseKey: "myVehicle.vehicleConditionAndLocation.whenCanMove")
					vehicle.vehicleLocationAddress1 = fnolClaim.value(forResponseKey: "myVehicle.vehicleConditionAndLocation.street")
					vehicle.vehicleLocationAddress2 = fnolClaim.value(forResponseKey: "myVehicle.vehicleConditionAndLocation.addressDetail1")
					vehicle.vehicleLocationCity = fnolClaim.value(forResponseKey: "myVehicle.vehicleConditionAndLocation.city")
					vehicle.vehicleLocationState = fnolClaim.value(forResponseKey: "myVehicle.vehicleConditionAndLocation.state")
					vehicle.vehicleLocationZip = fnolClaim.value(forResponseKey: "myVehicle.vehicleConditionAndLocation.zip")
					
					// TODO: TODO: Figure out what to do about this
					vehicle.suspensionOrFrame = (fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.suspensionOrFrame") != nil) ? 1 : 0
					
					// Vehicle damage details
					var vehicleDamageDetails = VehicleDamageDetails()
					vehicleDamageDetails.airbagsDeployed = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.airbagsDeployed"))
					vehicleDamageDetails.airbagsStolen = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.airbagsStolen"))
					vehicleDamageDetails.dentSizeOfBaseball = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.dentSizeOfBaseball"))
					vehicleDamageDetails.deviceToFreeOccupants = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.deviceToFreeOccupants"))
					vehicleDamageDetails.doorsOperable = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.doorsOpenable"))
					vehicleDamageDetails.engineStarts = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.engineStarts"))
					vehicleDamageDetails.engineSubmerged = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.engineSubmerged"))
					vehicleDamageDetails.fireBurnDash = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.fireBurnDash"))
					vehicleDamageDetails.fireBurnEngine = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.fireBurnEngine"))
					vehicleDamageDetails.fireBurnFrontHalfOfVehicle = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.fireBurnFrontHalfOfVehicle"))
					vehicleDamageDetails.fireBurnRearHalfVehicle = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.fireBurnRearHalfVehicle"))
					vehicleDamageDetails.fireBurnSeats = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.fireBurnSeats"))
					vehicleDamageDetails.fireElectrical = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.fireElectrical"))
					vehicleDamageDetails.floodSaltWater = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.floodSaltwater"))
					vehicleDamageDetails.fluidsLeaking = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.fluidsLeaking"))
					vehicleDamageDetails.glassByHail = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.glassbyHail"))
					vehicleDamageDetails.hailDamageAtLeast3BodyPanels = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.HailDamageAtLeast3BodyPanels"))
					vehicleDamageDetails.interiorMissing = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.interiorMissing"))
					vehicleDamageDetails.seatsorDashboard = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.seatOrDashboard"))
					vehicleDamageDetails.theftDamageToAtLeast3BodyPanels = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.theftDamagetoAtleast3Bodypanels"))
					vehicleDamageDetails.waterLevelDash = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.waterLevelDash"))
					vehicleDamageDetails.waterLevelSeats = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.waterLevelSeats"))
					vehicleDamageDetails.wheelsTiresStolen = yesNoValue(code: fnolClaim.value(forResponseKey: "myVehicle.vehicleDamageDetailsInfo.wheelsTiresStolen"))
					vehicle.damageDetails = vehicleDamageDetails

					// Vehicle damaged parts
					if let damagedParts = fnolClaim.damagedPartsArray {
						var vehicleDamagedParts = VehicleDamagedParts()
						if damagedParts.filter({ $0.code! == "driverfender" }).count > 0 { vehicleDamagedParts.driverFender = "yes" }
						if damagedParts.filter({ $0.code! == "driverfrontdoor" }).count > 0 { vehicleDamagedParts.driverFrontDoor = "yes" }
						if damagedParts.filter({ $0.code! == "driverfrontwheel" }).count > 0 { vehicleDamagedParts.driverFrontWheel = "yes" }
						if damagedParts.filter({ $0.code! == "driverquarterpanel" }).count > 0 { vehicleDamagedParts.driverQuarterPanel = "yes" }
						if damagedParts.filter({ $0.code! == "driverreardoor" }).count > 0 { vehicleDamagedParts.driverReadDoor = "yes" }
						if damagedParts.filter({ $0.code! == "driverrearwheel" }).count > 0 { vehicleDamagedParts.driverRearWheel = "yes" }
						if damagedParts.filter({ $0.code! == "frontbumper" }).count > 0 { vehicleDamagedParts.frontBumper = "yes" }
						if damagedParts.filter({ $0.code! == "hood" }).count > 0 { vehicleDamagedParts.hood = "yes" }
						if damagedParts.filter({ $0.code! == "passengerfender" }).count > 0 { vehicleDamagedParts.passengerFender = "yes" }
						if damagedParts.filter({ $0.code! == "passengerfrontdoor" }).count > 0 { vehicleDamagedParts.passengerFrontDoor = "yes" }
						if damagedParts.filter({ $0.code! == "passengerfrontwheel" }).count > 0 { vehicleDamagedParts.passengerFrontWheel = "yes" }
						if damagedParts.filter({ $0.code! == "passengerquarterpanel" }).count > 0 { vehicleDamagedParts.passengerQuarterPanel = "yes" }
						if damagedParts.filter({ $0.code! == "passengerreardoor" }).count > 0 { vehicleDamagedParts.passengerRearDoor = "yes" }
						if damagedParts.filter({ $0.code! == "passengerrearwheel" }).count > 0 { vehicleDamagedParts.passengerRearWheel = "yes" }
						if damagedParts.filter({ $0.code! == "rearbumper" }).count > 0 { vehicleDamagedParts.rearBumper = "yes" }
						if damagedParts.filter({ $0.code! == "roof" }).count > 0 { vehicleDamagedParts.roof = "yes" }
						if damagedParts.filter({ $0.code! == "trunk" }).count > 0 { vehicleDamagedParts.trunk = "yes" }
						if damagedParts.filter({ $0.code! == "windshield" }).count > 0 { vehicleDamagedParts.windShield = "yes" }
						vehicle.damagedParts = vehicleDamagedParts
					}

					// Vehicle person list
					vehicle.vehiclePersonList = [VehiclePerson]()
					if let people = v.people?.allObjects as? [FNOLPerson] {
						for person in people {
							let type = person.isDriver ? NSLocalizedString("driverinfo.driver", comment: "Driver") : NSLocalizedString("claimreview.passenger", comment: "Passenger")
							let newPerson = VehiclePerson(address1: person.addressDetail1, address2: person.addressDetail2, address3: nil, city: person.city, injured: person.injured, injuryType: person.injuryType, injuryDetails: person.injuryDetails, name: "\(person.firstName ?? "") \(person.lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines), phoneNumber: person.phoneNumber, postalCode: person.zip, state: person.state, transportedFromScene: person.transportedFromScene, type: type)
							vehicle.vehiclePersonList?.append(newPerson)
						}
					}
				}
				vehicleList.append(vehicle)
			}
		}
		let predicate = NSPredicate(format: "claim == %@", fnolClaim)
		if let otherPeople = FNOLPerson.mr_findAll(with: predicate) as? [FNOLPerson] {
			partyInvolvedList = [PartyInvolved]()
			for otherPerson in otherPeople {
				if !otherPerson.isPassenger && !otherPerson.isDriver {
					let name = "\(otherPerson.firstName ?? "") \(otherPerson.lastName ?? "")"
					var type: String? = nil
					if let _ = otherPerson.isWitness {
						type = "Witness"
					}
					let transportedFromScene: Int? = otherPerson.transportedFromScene == "yes" ? 1 : nil
					let partyInvolved = PartyInvolved(name: name, type: type, transportedFromScene: transportedFromScene, injured: otherPerson.injured, injuryDetails: otherPerson.injuryDetails, injuryType: otherPerson.injuryType)
					partyInvolvedList?.append(partyInvolved)
				}
			}
		}
	}
	
	func yesNoValue(code: String?) -> String? {
		if let code = code {
			switch code {
			case "yes": return "Yes"
			case "no": return "No"
			case "i_dont_know": return "I don't know"
			default: return nil
			}
		}
		return nil
	}
	
	/// Generate Claim from FNOLClaim for display in Claims area of app
	///
	/// - Returns: Claim
	init(claimResponse: ClaimResponse) {
		message = claimResponse.claimDetail?.message
		status = claimResponse.claimDetail?.status
		address1 = claimResponse.claimDetail?.claimInformation?.address1
		address2 = claimResponse.claimDetail?.claimInformation?.address2
		address3 = claimResponse.claimDetail?.claimInformation?.address3
		city = claimResponse.claimDetail?.claimInformation?.city
		claimNumber = claimResponse.claimDetail?.claimInformation?.claimNumber
		
		// Fix format of loss date
		var inputDateFormatter = DateFormatter.twoDigitMonthDayFourDigitYear
		if let returnedDateString = claimResponse.claimDetail?.claimInformation?.lossDate, let lossDateAsDate = inputDateFormatter.date(from: returnedDateString) {
			let outputDateFormatter = DateFormatter.monthDayYear
			lossDate = outputDateFormatter.string(from: lossDateAsDate)
		} else {
			lossDate = claimResponse.claimDetail?.claimInformation?.lossDate
		}
		
		// Fix format of loss time
		inputDateFormatter = DateFormatter.hoursCivilian
		if let returnedTimeString = claimResponse.claimDetail?.claimInformation?.lossTime, let lossTimeAsDate = inputDateFormatter.date(from: returnedTimeString) {
			let outputDateFormatter = DateFormatter.hourMinuteMeridiemTimezone
			lossTime = outputDateFormatter.string(from: lossTimeAsDate)
		} else {
			lossTime = claimResponse.claimDetail?.claimInformation?.lossTime
		}

		lossLocation = claimResponse.claimDetail?.claimInformation?.lossLocation
		lossType = claimResponse.claimDetail?.claimInformation?.lossType
		nextStep = claimResponse.claimDetail?.claimInformation?.nextStep
		nextStepNumber = claimResponse.claimDetail?.claimInformation?.nextStepNumber
		nextStepTitle = claimResponse.claimDetail?.claimInformation?.nextStepTitle
		postalCode = claimResponse.claimDetail?.claimInformation?.postalCode
		state = claimResponse.claimDetail?.claimInformation?.state
		totalSteps = claimResponse.claimDetail?.claimInformation?.totalSteps
		
		partyInvolvedList = [PartyInvolved]()
		if let claimPartyInvolvedList = claimResponse.claimDetail?.partyInvolvedList {
			for claimPartyInvolved in claimPartyInvolvedList {
				partyInvolvedList!.append(PartyInvolved(claimPartyInvolved: claimPartyInvolved))
			}
		}
		
		vehicleList = [Vehicle]()
		if let responseVehicleList = claimResponse.claimDetail?.vehicleList {
			for responseVehicle in responseVehicleList {
				var vehicle = Vehicle()
				vehicle.color = responseVehicle.color
				vehicle.dateAvailableToMove = responseVehicle.dateAvailableToMove
				vehicle.drivable = (responseVehicle.drivable != 0)
				vehicle.licensePlate = responseVehicle.licensePlate
				vehicle.make = responseVehicle.make
				vehicle.model = responseVehicle.model
				vehicle.permissionToMove = responseVehicle.permissionToMove
				vehicle.policyVehicle = responseVehicle.policyVehicle
				vehicle.severityOfDamage = responseVehicle.severityOfDamage
				vehicle.suspensionOrFrame = responseVehicle.suspensionOrFrame
				vehicle.vehicleLocationAddress1 = responseVehicle.vehicleLocationAddress1
				vehicle.vehicleLocationAddress2 = responseVehicle.vehicleLocationAddress2
				vehicle.vehicleLocationAddress3 = responseVehicle.vehicleLocationAddress3
				vehicle.vehicleLocationCity = responseVehicle.vehicleLocationCity
				vehicle.vehicleLocationState = responseVehicle.vehicleLocationCity
				vehicle.vehicleLocationZip = responseVehicle.vehicleLocationZip
				vehicle.vehicleOwner = responseVehicle.vehicleOwner
				if let year = responseVehicle.year {
					vehicle.year = "\(year)"
				}
				vehicle.vehiclePersonList = [VehiclePerson]()
				if let vehiclePersonList = responseVehicle.vehiclePersonList {
					for claimVehiclePerson in vehiclePersonList {
						vehicle.vehiclePersonList!.append(VehiclePerson(claimVehiclePerson: claimVehiclePerson))
					}
				}
				
				// Vehicle damage details
				var vehicleDamageDetails = VehicleDamageDetails()
				
				// TODO: Remove string interpolation when all of these come back as strings
				vehicleDamageDetails.airbagsDeployed = "\(responseVehicle.airbagsDeployed)"
				vehicleDamageDetails.airbagsStolen = responseVehicle.airbagsStolen
				vehicleDamageDetails.dentSizeOfBaseball = responseVehicle.dentSizeOfBaseball
				vehicleDamageDetails.deviceToFreeOccupants = "\(responseVehicle.deviceToFreeOccupants)"
				vehicleDamageDetails.doorsOperable = "\(responseVehicle.doorsOperable)"
				vehicleDamageDetails.engineStarts = responseVehicle.engineStarts
				vehicleDamageDetails.engineSubmerged = responseVehicle.engineSubmerged
				vehicleDamageDetails.fireBurnDash = responseVehicle.fireBurnDash
				vehicleDamageDetails.fireBurnEngine = responseVehicle.fireBurnEngine
				vehicleDamageDetails.fireBurnFrontHalfOfVehicle = responseVehicle.fireBurnFrontHalfOfVehicle
				vehicleDamageDetails.fireBurnRearHalfVehicle = responseVehicle.fireBurnRearHalfVehicle
				vehicleDamageDetails.fireBurnSeats = responseVehicle.fireBurnSeats
				vehicleDamageDetails.fireElectrical = responseVehicle.fireElectrical
				vehicleDamageDetails.floodSaltWater = responseVehicle.floodSaltWater
				vehicleDamageDetails.fluidsLeaking = "\(responseVehicle.fluidsLeaking)"
				vehicleDamageDetails.glassByHail = responseVehicle.glassByHail
				vehicleDamageDetails.hailDamageAtLeast3BodyPanels = responseVehicle.hailDamageAtLeast3BodyPanels
				vehicleDamageDetails.interiorMissing = responseVehicle.interiorMissing
				vehicleDamageDetails.seatsorDashboard = "\(responseVehicle.seatsorDashboard)"
				
				vehicleDamageDetails.theftDamageToAtLeast3BodyPanels = responseVehicle.theftDamageToAtLeast3BodyPanels
				vehicleDamageDetails.waterLevelDash = responseVehicle.waterLevelDash
				vehicleDamageDetails.waterLevelSeats = responseVehicle.waterLevelSeats
				vehicleDamageDetails.wheelsTiresStolen = responseVehicle.wheelsTiresStolen
				vehicle.damageDetails = vehicleDamageDetails
				
				// Vehicle damaged parts
				var vehicleDamagedParts = VehicleDamagedParts()
				vehicleDamagedParts.driverFender = responseVehicle.driverFender
				vehicleDamagedParts.driverFrontDoor = responseVehicle.driverFrontDoor
				vehicleDamagedParts.driverFrontWheel = responseVehicle.driverFrontWheel
				vehicleDamagedParts.driverQuarterPanel = responseVehicle.driverQuarterPanel
				vehicleDamagedParts.driverReadDoor = responseVehicle.driverReadDoor
				vehicleDamagedParts.driverRearWheel = responseVehicle.driverRearWheel
				vehicleDamagedParts.frontBumper = responseVehicle.frontBumper
				vehicleDamagedParts.hood = responseVehicle.hood
				vehicleDamagedParts.passengerFender = responseVehicle.passengerFender
				vehicleDamagedParts.passengerFrontDoor = responseVehicle.passengerFrontDoor
				vehicleDamagedParts.passengerFrontWheel = responseVehicle.passengerFrontWheel
				vehicleDamagedParts.passengerQuarterPanel = responseVehicle.passengerQuarterPanel
				vehicleDamagedParts.passengerRearDoor = responseVehicle.passengerRearDoor
				vehicleDamagedParts.passengerRearWheel = responseVehicle.passengerRearWheel
				vehicleDamagedParts.rearBumper = responseVehicle.rearBumper
				vehicleDamagedParts.roof = responseVehicle.roof
				vehicleDamagedParts.trunk = responseVehicle.trunk
				vehicleDamagedParts.windShield = responseVehicle.windShield
				vehicle.damagedParts = vehicleDamagedParts

				vehicleList.append(vehicle)
			}
		}
	}
	
}
