//
//  Value+CoreDataClass.swift
//  The General
//
//  Created by Derek Bowen on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import CoreData
import MagicalRecord

@objc(Value)
public class Value: NSManagedObject {
    /// - Service Response Parsing
    func populate(fromResponse response: ValueResponse, inContext context: NSManagedObjectContext) {
        self.code = response.code
        self.value = response.value
    }
}
