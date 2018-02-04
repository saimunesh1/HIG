//
//  ClaimResponse.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/12/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

enum ClaimStatus: String {
	case draftSaved = "Draft saved"
	case uploadingClaim = "Uploading claim"
	case claimSaved = "Claim saved"
	case claimSubmitted = "Claim submitted"
	case claimEstablished = "Claim established"
	case appraisalRequested = "Appraisal requested" // TODO: May not need this
	case resolved = "Resolved"
}

struct ClaimPartyInvolved:  Decodable {
	let injured: String?
	let injuryDetails: String?
	let injuryType: String?
	let name: String?
	let transportedFromScene: Int?
	let type: String?
}

struct ClaimVehiclePerson: Decodable {
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
}

struct ClaimVehicle: Decodable {
	let airbagsDeployed: Bool?
	let airbagsStolen: String?
	let color: String?
	let damageDesc: String?
	let damageSeverity: String?
	let dateAvailableToMove: String?
	let dentSizeOfBaseball: String?
	let deviceToFreeOccupants: Int?
	let doorsOperable: Int?
	let drivable: Int?
	let driverFender: String?
	let driverFrontDoor: String?
	let driverFrontWheel: String?
	let driverQuarterPanel: String?
	let driverReadDoor: String?
	let driverRearWheel: String?
	let engineStarts: String?
	let engineSubmerged: String?
	let fireBurnDash: String?
	let fireBurnEngine: String?
	let fireBurnFrontHalfOfVehicle: String?
	let fireBurnRearHalfVehicle: String?
	let fireBurnSeats: String?
	let fireElectrical: String?
	let floodSaltWater: String?
	let fluidsLeaking: Int?
	let frontBumper: String?
	let glassByHail: String?
	let hailDamageAtLeast3BodyPanels: String?
	let hood: String?
	let insuredLoss: String?
	let interiorMissing: String?
	let licensePlate: String?
	let make: String?
	let model: String?
	let passengerFender: String?
	let passengerFrontDoor: String?
	let passengerFrontWheel: String?
	let passengerQuarterPanel: String?
	let passengerRearDoor: String?
	let passengerRearWheel: String?
	let permissionToMove: Bool?
	let policyVehicle: Int?
	let rearBumper: String?
	let roof: String?
	let seatsorDashboard: Int?
	let severityOfDamage: Int?
	let suspensionOrFrame: Int?
	let theftDamageToAtLeast3BodyPanels: String?
	let trunk: String?
	let vehicleLocationAddress1: String?
	let vehicleLocationAddress2: String?
	let vehicleLocationAddress3: String?
	let vehicleLocationCity: String?
	let vehicleLocationCountry: String?
	let vehicleLocationState: String?
	let vehicleLocationZip: String?
	let vehicleOwner: String?
	let vehiclePersonList: [ClaimVehiclePerson]?
	let vin: String?
	let waterLevelDash: String?
	let waterLevelSeats: String?
	let wheelsTiresStolen: String?
	let windShield: String?
	let year: Int?
}

struct ClaimInformation: Decodable {
	let address1: String?
	let address2: String?
	let address3: String?
	let city: String?
	let claimNumber: String?
	let lossDate: String?
	let lossLocation: String?
	let lossTime: String?
	let lossType: String?
	let nextStep: String?
	let nextStepDescription: String?
	let nextStepNumber: Int?
	let nextStepTitle: String?
	let postalCode: String?
	let referenceNumber: Int?
	let state: String?
	let totalSteps: Int?
}

struct ClaimDetail: Decodable {
	let claimInformation: ClaimInformation?
	let message: String?
	let partyInvolvedList: [ClaimPartyInvolved]?
	let status: Int?
	let vehicleList: [ClaimVehicle]?
}

struct ClaimResponse: Decodable {
	let claimDetail: ClaimDetail?
}
