//
//  Page+CoreDataClass.swift
//  The General
//
//  Created by Derek Bowen on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import CoreData
import MagicalRecord

@objc(Page)
public class Page: NSManagedObject {
    func getCurrentSection() -> Section? {
        return self.sectionsArray?.first
    }
    
    /// - Service Response Parsing
    func populate(fromResponse response: PageResponse, inContext context: NSManagedObjectContext) {
        self.pageId = response.pageId
        self.pageName = response.pageName
        
        if let sections = response.sections {
            for section in sections {
                let moSection = Section.mr_createEntity(in: context)!
                moSection.populate(fromResponse: section, inContext: context)
                self.addToSections(moSection)
            }
        }
    }
    
    /// - Relationships
    var sectionsArray: [Section]? {
        return self.sections?.array as? [Section]
    }
}
