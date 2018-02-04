//
//  FNOLDamagedPart+CoreDataClass.swift
//  
//
//  Created by Bowen, Derek (US - Denver) on 11/16/17.
//
//

import Foundation
import CoreData

@objc(FNOLDamagedPart)
public class FNOLDamagedPart: NSManagedObject {
    // - Relationships
    var imagesArray: [FNOLImage]? {
        return self.images?.allObjects as? [FNOLImage]
    }
}
