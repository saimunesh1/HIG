//
//  CoreDataExtensions.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import CoreData
import MagicalRecord

extension NSManagedObject {
    
    //Helper
    // Cretae a shallow copy
    func shallowCopy() -> NSManagedObject? {
        guard let context = managedObjectContext, let entityName = entity.name else { return nil }
        let copy = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        let attributes = entity.attributesByName
        for (attrKey, _) in attributes {
            copy.setValue(value(forKey: attrKey), forKey: attrKey)
        }
        return copy
    }
}
