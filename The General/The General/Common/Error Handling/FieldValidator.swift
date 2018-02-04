//
//  FieldValidator.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public struct FieldValidatorDictionary<T> : Sequence {
    
    private var innerDictionary: [ObjectIdentifier: T] = [:];
    
    public subscript(key: FieldToValidate?) -> T? {
        get {
            if let key = key {
                return innerDictionary[ObjectIdentifier(key)];
            } else {
                return nil;
            }
        }
        set(newValue) {
            if let key = key {
                innerDictionary[ObjectIdentifier(key)] = newValue;
            }
        }
    }
    
    public mutating func removeAll() {
        innerDictionary.removeAll()
    }
    
    public mutating func removeValueForKey(_ key: FieldToValidate) {
        innerDictionary.removeValue(forKey: ObjectIdentifier(key))
    }
    
    public var isEmpty: Bool {
        return innerDictionary.isEmpty
    }
    
    public func makeIterator() -> DictionaryIterator<ObjectIdentifier , T> {
        return innerDictionary.makeIterator()
    }
}
