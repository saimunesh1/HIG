//
//  Questionnaire.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

enum CellType: String, Decodable {
	case addDriverButton = "addDriverButton"
	case additionalDetails = "details_input"
	case addPassengerButton = "addPassengerButton"
	case addPersonButton = "addPersonButton"
	case address = "address"
	case addressType = "addAddressButton"
	case damageDetailPickList = "damage_detail_pick_list"
	case damagePickList = "damage_part_pick_list"
	case datePicker = "datepicker"
	case driverPickList = "driver_picklist"
	case ownerPickList = "owner_picklist"
	case phoneNumber = "phoneNumber"
	case photoCell = "peoplePictureType"
	case pickList = "picklist"
	case pictureType = "picture"
	case quickPick = "location_quick_pick"
	case segmentedControlCell = "segmentedControlCell"
	case severityPickList = "severity_pick_list"
	case textBox = "textbox"
	case timePicker = "timepicker"
	case toggleType = "toggle"
	case vehicleConditionLocation = "vehicleConditionButton"
	case vehicleLocationPickList = "vehicle_location_quick_pick"
	case vehicleMakePickup = "vehicle_make_pickup"
	case vehicleModelPickup = "vehicle_model_pickup"
	case vehiclePickList = "vehicle_picklist"
	case vehicleYearPicker = "vehicle_year_pickup"
	case vinNumber = "vin_number"
    case unknown = ""
}

struct ValueResponse: Decodable {
    let code: String?
    let value: String?
}

struct ParentValueResponse: Decodable {
    let value: ValueResponse?
}

struct RuleResponse: Decodable {
    let parentFieldResponseKey: String?
    let parentValues: [ParentValueResponse]?
}

struct FieldResponse: Decodable {
    let label: String?
    let title: String?
    let type: CellType?
    var defaultValue: String?
    let placeHolder: String?
    let responseKey: String?
    let required: Bool
    let onlyDisplay: Bool
    let rules: [RuleResponse]?
    let showSubFieldsInNewPage: Bool
    let showValuesInNewPage: Bool
    let order: Int16
    let validValues: [ValueResponse]?
    let validations: [String]?
    let subFields: [FieldResponse]?
}

struct SectionResponse: Decodable {
    let sectionName: String?
    let showInNewPage: Bool
    let sectionOrder: Int16
    var fields: [FieldResponse]?
}

struct PageResponse: Decodable {
    let pageId: String
    let pageName: String
    let sections: [SectionResponse]?
}

struct DriverInfoResponse: Decodable {
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let addressDetail1: String?
    let addressDetail2: String?
    let city: String?
    let state: String?
    let zip: String?
    let country: String?
	
	func isEqualTo(driverInfo: DriverInfo) -> Bool {
		return self.firstName == driverInfo.firstName &&
			self.lastName == driverInfo.lastName &&
			self.phoneNumber == driverInfo.phoneNumber &&
			self.addressDetail1 == driverInfo.addressDetail1 &&
			self.addressDetail2 == driverInfo.addressDetail2 &&
			self.city == driverInfo.city &&
			self.state == driverInfo.state &&
			self.zip == driverInfo.zip &&
			self.country == driverInfo.country
	}
}

struct VehicleInfoResponse: Decodable {
    let make: String?
    let model: String?
    let year: String?
    let licensePlate: String?
    let riskUnit: String?
    let vin: String?
	
	func isEqualTo(vehicleInfo: VehicleInfo) -> Bool {
		return self.make == vehicleInfo.make &&
		self.model == vehicleInfo.model &&
		self.year == vehicleInfo.year &&
		self.licensePlate == vehicleInfo.licensePlate &&
		self.riskUnit == vehicleInfo.riskUnit &&
		self.vin == vehicleInfo.vin
	}
}

struct AddressInfoResponse: Decodable {
    let type: String?
    var street: String?
    var addressDetail1: String?
    var addressDetail2: String?
    var city: String?
    var state: String?
    var zip: String?
    var country: String?
}

struct QuestionnaireResponse: Decodable {
    let pages: [PageResponse]?
    let driverInfos: [DriverInfoResponse]?
    let vehicleInfos: [VehicleInfoResponse]?
    let addressInfos: [AddressInfoResponse]?
}
