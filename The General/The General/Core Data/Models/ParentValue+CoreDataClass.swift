//
//  ParentValue+CoreDataClass.swift
//  The General
//
//  Created by Derek Bowen on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import CoreData
import MagicalRecord

@objc(ParentValue)
public class ParentValue: NSManagedObject {
    /// - Service Response Parsing
    func populate(fromResponse response: ParentValueResponse, inContext context: NSManagedObjectContext) {
        if let value = response.value {
            let moValue = Value.mr_createEntity(in: context)!
            moValue.populate(fromResponse: value, inContext: context)
            self.value = moValue
        }
    }
}
