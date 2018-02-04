//
//  DriverInfo+CoreDataClass.swift
//  The General
//
//  Created by Derek Bowen on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import CoreData
import MagicalRecord

@objc(DriverInfo)
public class DriverInfo: NSManagedObject {
    /// - Service Response Parsing
    func populate(fromResponse response: DriverInfoResponse, inContext context: NSManagedObjectContext) {
        self.addressDetail1 = response.addressDetail1
        self.addressDetail2 = response.addressDetail2
        self.city = response.city
        self.country = response.country
        self.firstName = response.firstName
        self.lastName = response.lastName
        self.phoneNumber = response.phoneNumber
        self.state = response.state
        self.zip = response.zip
    }
}
