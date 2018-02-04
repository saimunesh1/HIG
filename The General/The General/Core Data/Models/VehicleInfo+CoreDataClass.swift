//
//  VehicleInfo+CoreDataClass.swift
//  The General
//
//  Created by Derek Bowen on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import CoreData
import MagicalRecord

@objc(VehicleInfo)
public class VehicleInfo: NSManagedObject {
    /// - Service Response Parsing
    func populate(fromResponse response: VehicleInfoResponse, inContext context: NSManagedObjectContext) {
        self.licensePlate = response.licensePlate
        self.make = response.make
        self.model = response.model
        self.riskUnit = response.riskUnit
        self.vin = response.vin
        self.year = response.year
    }

}
