//
//  VehicleConditionTemporary.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/16/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public struct VehicleConditionTemporary {
    
    public func valueFor(responseKey: String) -> Any? {
        if let suffix = responseKey.components(separatedBy: ".").last {
            switch suffix {
    
            default:
                return nil
            }
        }
        return nil
    }
    
    public mutating func update(value: Any?, forResponseKey responseKey: String) {
        if let suffix = responseKey.components(separatedBy: ".").last {
            switch suffix {
           
            default:
                break
            }
        }
    }
    
}
