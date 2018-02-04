//
//  Dictionary+KeyPaths.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating public func set(_ value: Value, forKeyPath keyPath: String) {
        var keyPathComponents = keyPath.components(separatedBy: ".")
        
        guard let firstKey = keyPathComponents.first as? Key else {
            debugPrint("Type mismatch: \(Key.self) does not conform to String")
            return
        }
        keyPathComponents.removeFirst()
        
        if keyPathComponents.isEmpty {
            self[firstKey] = value
        }
        else {
            let remainingKeyPath = keyPathComponents.joined(separator: ".")
            
            var childDictionary: [Key: Value] = [:]
            if let child = self[firstKey] as? [Key: Value] {
                childDictionary = child
            }
            
            childDictionary.set(value, forKeyPath: remainingKeyPath)
            if let value = childDictionary as? Value {
                self[firstKey] = value
            }
            else {
                debugPrint("Failed to set value: \(childDictionary) to dictionary of type: \(type(of: self))")
            }
        }
    }
}
