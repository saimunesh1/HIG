//
//  PersistenceManager.swift
//  The General
//
//  Created by Derek Bowen on 10/31/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord

protocol StructRepresentable {
    associatedtype StructType
    var `struct`: StructType { get }
}

protocol CoreDataRepresentable {
    associatedtype Value: NSManagedObject
    var managedObject: Value { get }
}

class PersistenceManager {
    typealias SaveOperationHandler = (NSManagedObjectContext) -> Void
    typealias SaveCompletionHandler = (Bool, Error?) -> Void
    static let shared = PersistenceManager()
    
    init() {
        MagicalRecord.setupAutoMigratingCoreDataStack()
    }
    
    /// Perform save operation in the background
    ///
    /// - Parameters:
    ///   - saveOperation: Work to be saved, everything should be done against this context
    ///   - completion: Fired when the save operation is completed
    func save(_ saveOperation: SaveOperationHandler? = nil, completion: SaveCompletionHandler? = nil) {
        MagicalRecord.save({ (context) in
            print(context)
            saveOperation?(context)
        }) { (success, error) in
            completion?(success, error)
        }
    }
    
    /// Save default context to persistent store
    ///
    /// - Parameter completion: Fire when save operation is completed
    func saveToPersistentStore(_ completion: SaveCompletionHandler? = nil) {
        DispatchQueue.main.async {
            NSManagedObjectContext.mr_default().mr_saveToPersistentStore { (success, error) in
                completion?(success, error)
            }
        }
    }
}

extension PersistenceManager {
}
