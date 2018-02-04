//
//  AddressInfo+CoreDataClass.swift
//  The General
//
//  Created by Derek Bowen on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import CoreData
import MagicalRecord

@objc(AddressInfo)
public class AddressInfo: NSManagedObject {
    func getAddressFor(type: String) -> AddressInfo? {
        if self.type == type {
            return self
        }
        return nil
    }
    
    /// - Service Response Parsing
    func populate(fromResponse response: AddressInfoResponse, inContext context: NSManagedObjectContext) {
        self.addressDetail1 = response.addressDetail1
        self.addressDetail2 = response.addressDetail2
        self.city = response.city
        self.country = response.country
        self.state = response.state
        self.type = response.type
        self.zip = response.zip
    }
  
	static func fetchSavedAddress(handler: @escaping (FNOLAddressTemporary) -> Void) {
		var savedClaimAddress = FNOLAddressTemporary()
		savedClaimAddress.city = getClaimValue(forResponseKey: "accidentDetails.address.city")
		savedClaimAddress.street = getClaimValue(forResponseKey: "accidentDetails.address.street")
		savedClaimAddress.zip = getClaimValue(forResponseKey: "accidentDetails.address.zip")
		savedClaimAddress.addressDetail1 = getClaimValue(forResponseKey: "accidentDetails.address.addressDetail1")?.lowercased().capitalized
		savedClaimAddress.addressDetail2 = getClaimValue(forResponseKey: "accidentDetails.address.addressDetail2")?.lowercased().capitalized
		savedClaimAddress.state = getClaimValue(forResponseKey: "accidentDetails.address.state")
		savedClaimAddress.country = getClaimValue(forResponseKey: "accidentDetails.address.country")?.lowercased().capitalized
		handler(savedClaimAddress)
	}
	
	static func fetchVehicleConditionAddress(handler: @escaping (FNOLAddressTemporary) -> Void) {
		var savedConditionAddress = FNOLAddressTemporary()
		savedConditionAddress.city = getClaimValue(forResponseKey: "myVehicle.vehicleConditionAndLocation.city")
		savedConditionAddress.street = getClaimValue(forResponseKey: "myVehicle.vehicleConditionAndLocation.street")
		savedConditionAddress.zip = getClaimValue(forResponseKey: "myVehicle.vehicleConditionAndLocation.zip")
		savedConditionAddress.addressDetail1 = getClaimValue(forResponseKey: "myVehicle.vehicleConditionAndLocation.addressDetail1")?.lowercased().capitalized
		savedConditionAddress.addressDetail2 = getClaimValue(forResponseKey: "myVehicle.vehicleConditionAndLocation.addressDetail2")?.lowercased().capitalized
		savedConditionAddress.state = getClaimValue(forResponseKey: "myVehicle.vehicleConditionAndLocation.state")
		savedConditionAddress.country = getClaimValue(forResponseKey: "myVehicle.vehicleConditionAndLocation.country")?.lowercased().capitalized
		handler(savedConditionAddress)
	}
	
	static func getClaimValue(forResponseKey responseKey: String) -> String? {
		guard let value = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: responseKey) else {
			return ""
		}
		return value
	}
	
}
