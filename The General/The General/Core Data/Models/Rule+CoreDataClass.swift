//
//  Rule+CoreDataClass.swift
//  The General
//
//  Created by Derek Bowen on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import CoreData
import MagicalRecord

@objc(Rule)
public class Rule: NSManagedObject {
    
    /// - Service Response Parsing
    func populate(fromResponse response: RuleResponse, inContext context: NSManagedObjectContext) {
        self.parentFieldResponseKey = response.parentFieldResponseKey
        
        if let parentValues = response.parentValues {
            for parentValue in parentValues {
                let moParentValue = ParentValue.mr_createEntity(in: context)!
                moParentValue.populate(fromResponse: parentValue, inContext: context)
                self.addToParentValues(moParentValue)
            }
        }
    }
    
    // - Relationships
    var parentValuesArray: [ParentValue]? {
        return self.parentValues?.allObjects as? [ParentValue]
    }
}
