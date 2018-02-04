//
//  QuestionaireModel.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

enum CellType:String, Codable {
    
    case pickList = "picklist"
    case datePicker = "datepicker"
    case timePicker = "timepicker"
    case quickPick = "location_quick_pick"
    case vehicleLocationPickList = "vehicle_location_quick_pick"
    case addressType = "addAddressButton"
    case vehicleConditionLocation = "vehicleConditionButton"
    case addDriverButton = "addDriverButton"
    case addPassengerButton = "addPassengerButton"
    case addPersonButton = "addPersonButton"
    case textBox = "textbox"
    case vehiclePickList = "vehicle_picklist"
    case damagedDetailPickList = "damage_detail_pick_list"
    case ownerPickList = "owner_picklist"
    case pictureType = "picture"
    case toggleType = "toggle"
    case vehicleYearPickup = "vehicle_year_pickup"
    case vehicleMakePickup = "vehicle_make_pickup"
    case vehiclModelPickup = "vehicle_model_pickup"
    case damagePickList = "damage_part_pick_list"
    case driverPickList = "driver_picklist"
    case severityPickList = "severity_pick_list"
    case additionalDetails = "details_input"
    case unknown = ""
    
}

struct Value:Codable, Equatable {
    let code: String?
    let value: String?
    // Implement Equatable
    static func ==(lhs: Value, rhs: Value) -> Bool {
        return lhs.code == rhs.code
    }
}


struct ParentValue:Codable {
    let value: Value?
}

struct Rule:Codable  {
    let parentFieldResponseKey: String?
    let parentValues: [ParentValue]?
    
}

struct Field:Codable {
    
    let label: String?
    let title: String?
    let type: CellType?
    var defaultValue: String?
    let placeHolder: String?
    let responseKey: String?
    let required: Bool?
    let onlyDisplay: Bool?
    let rules: [Rule]?
    let showSubFieldsInNewPage: Bool?
    let showValuesInNewPage: Bool?
    let order: Int?
    let validValues: [Value]?
    let validations: [String]?
    let subFields: [Field]?
    
}

struct Section:Codable  {
    let sectionName: String?
    let showInNewPage: Bool?
    let sectionOrder: Int?
    var fields: [Field]?
    
}

struct Page:Codable {
    let pageId: String?
    let pageName: String?
    let sections: [Section]?
}

struct DriverInfo:Codable {
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let addressDetail1: String?
    let addressDetail2: String?
    let city: String?
    let state: String?
    let zip: String?
    let country: String?
    
}

struct VehicleInfo:Codable {
    let make: String?
    let model: String?
    let year: String?
    let licensePlate: String?
    let riskUnit: String?
    let vin: String?
}

struct AddressInfo:Codable {
    let type: String?
    var street: String?
    var addressDetail1: String?
    var addressDetail2: String?
    var city: String?
    var state: String?
    var zip: String?
    var country: String?
    
    init(type: String, street: String, addressDetail1: String?, addressDetail2: String, city: String?, zip: String, state: String?, country: String?) {
        self.type = type
        self.street = street
        self.addressDetail1 = addressDetail1
        self.addressDetail2 = addressDetail2
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
    }
    
    func getAddressFor(typ: String) -> AddressInfo? {
        if self.type == typ {
            return self
        }
        return nil
    }
    
}

struct Questionaire:Codable {
    let pages: [Page]?
    let driverInfos: [DriverInfo]?
    let vehicleInfos: [VehicleInfo]?
    let addressInfos: [AddressInfo]?
    
}

extension Questionaire {
    
    func getPageForId(id: String) -> Page? {
        let pages: [Page] = self.pages!.filter{$0.pageId == id}
        return pages.first
    }
    
    func getSectionList(pageID: String) -> [Section]? {
        return (getPageForId(id:pageID)?.sections)
    }
    
}

extension Page{
    
    func getCurrentSection() -> Section? {
        guard let sectionList = self.sections,
            let currentSection = sectionList.first else {
                return nil
        }
        return currentSection
    }
}

extension Section{
    
    func getFieldsForSection() -> [Field]? {
        guard let fielList = self.fields else {
            return []
        }
        return fielList
    }
    
    func getDuplicateRows(type: String) -> [Field] {
        guard let fields = self.fields else {
            return []
        }
        return fields.filter{$0.responseKey == type}
    }
    
    func getFieldForType(type: String) -> Field? {
        guard let fields = self.fields else {
            return nil
        }
        return fields.filter{$0.responseKey == type}.first
    }
}

extension Field {
    
    func getFieldValues() -> [Value]? {
        
        guard let valueList: [Value] = self.validValues
            else {
                return []
        }
        return valueList
    }
    
    func filterDuplicateRows() -> Bool {
        
        if self.rules?.first?.parentFieldResponseKey != "claim.vehicleCount" {
            return true
        }
        guard let rule = self.rules?.first,
            let selectedAccidentType = FNOLClaimsManager.fnolAnswerDictionary.value(forKey: rule.parentFieldResponseKey!) else {
                return true
        }
        let results: [ParentValue] = (rule.parentValues?.filter {el in el.value!.code == (selectedAccidentType as! String) })!
        if (results.count > 0) {
            return true
        }
        return false
    }
}
