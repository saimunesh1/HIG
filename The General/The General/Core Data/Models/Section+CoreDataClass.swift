//
//  Section+CoreDataClass.swift
//  The General
//
//  Created by Derek Bowen on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import CoreData
import MagicalRecord

@objc(Section)
public class Section: NSManagedObject {
    func getFieldsForSection() -> [Field]? {
        return self.fieldsArray?.filter({ $0.filterRows() }) ?? []
    }
    
    func getDuplicateRows(type: String) -> [Field] {
        return self.fieldsArray?.filter { $0.responseKey == type } ?? []
    }
    
    func getFieldForType(type: String) -> Field? {
        return self.fieldsArray?.filter({ $0.responseKey == type }).first
    }
    
    /// - Service Response Parsing
    func populate(fromResponse response: SectionResponse, inContext context: NSManagedObjectContext) {
        self.sectionName = response.sectionName
        self.sectionOrder = response.sectionOrder
        self.showInNewPage = response.showInNewPage
        
        if let fields = response.fields {
            for field in fields {
                let moField = Field.mr_createEntity(in: context)!
                moField.populate(fromResponse: field, inContext: context)
                self.addToFields(moField)
            }
        }
    }
    
    /// - Relationships
    var fieldsArray: [Field]? {
        return self.fields?.array as? [Field]
    }
}
