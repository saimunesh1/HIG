//
//  Questionnaire+CoreDataClass.swift
//  The General
//
//  Created by Derek Bowen on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import CoreData
import MagicalRecord

@objc(Questionnaire)
public class Questionnaire: NSManagedObject {
    func getPageForId(id: String) -> Page? {
        return self.pagesArray?.first(where: { $0.pageId == id })
    }
    
    func getSectionList(pageID: String) -> [Section]? {
        return self.getPageForId(id: pageID)?.sectionsArray
    }
    
    /// - Service Response Parsing
    func populate(fromResponse response: QuestionnaireResponse, inContext context: NSManagedObjectContext) {
        if let addressInfos = response.addressInfos {
            for addressInfo in addressInfos {
                let moAddressInfo = AddressInfo.mr_createEntity(in: context)!
                moAddressInfo.populate(fromResponse: addressInfo, inContext: context)
                self.addToAddressInfos(moAddressInfo)
            }
        }
        
        if let driverInfos = response.driverInfos {
			let existingVehicleInfos = DriverInfo.mr_findAll() as? [DriverInfo]
            for driverInfo in driverInfos {
				if let existingDriverInfos = existingVehicleInfos, let _ = existingDriverInfos.first(where: { driverInfo.isEqualTo(driverInfo:$0) }) {
					// DriverInfo already exists; don't add it
				} else {
					let moDriverInfo = DriverInfo.mr_createEntity(in: context)!
					moDriverInfo.populate(fromResponse: driverInfo, inContext: context)
					self.addToDriverInfos(moDriverInfo)
				}
            }
        }
        
        if let pages = response.pages {
            for page in pages {
                let moPage = Page.mr_createEntity(in: context)!
                moPage.populate(fromResponse: page, inContext: context)
                self.addToPages(moPage)
            }
        }
        
        if let vehicleInfos = response.vehicleInfos {
			let existingVehicleInfos = VehicleInfo.mr_findAll() as? [VehicleInfo]
			for vehicleInfo in vehicleInfos {
				if let existingVehicleInfos = existingVehicleInfos, let _ = existingVehicleInfos.first(where: { vehicleInfo.isEqualTo(vehicleInfo:$0) }) {
					// VehicleInfo already exists; don't add it
				} else {
					let moVehicleInfo = VehicleInfo.mr_createEntity(in: context)!
					moVehicleInfo.populate(fromResponse: vehicleInfo, inContext: context)
					self.addToVehicleInfos(moVehicleInfo)
				}
			}
        }
    }
    
    /// - Relationships
    var addressInfosArray: [AddressInfo]? {
        return self.addressInfos?.array as? [AddressInfo]
    }
    
    var driverInfosArray: [DriverInfo]? {
        return self.driverInfos?.array as? [DriverInfo]
    }
    
    var pagesArray: [Page]? {
        return self.pages?.array as? [Page]
    }
    
    var vehicleInfosArray: [VehicleInfo]? {
        return self.vehicleInfos?.array as? [VehicleInfo]
    }
}
