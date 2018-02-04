//
//  FNOLAccidentDetailsTemporary.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/16/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public struct FNOLAccidentDetailsTemporary {

    var type: String?
    var subType: String?
    var accidentPictures: String?
    var address: String?
    var locationInfo: String?
    var dateOfAccident: String?
    var timeOfAccident: String?
    var additionalDetails: String?
    

    public func valueFor(responseKey: String) -> Any? {
        if let suffix = responseKey.components(separatedBy: ".").last {
            switch suffix {
            case "type":
                return self.type
            case "subType":
                return self.subType
            case "accidentPictures":
                return self.accidentPictures
            case "address":
                return self.address
            case "locationInfo":
                return self.locationInfo
            case "dateOfAccident":
                return self.dateOfAccident
            case "timeOfAccident":
                return self.timeOfAccident
            case "additionalDetails":
                return self.additionalDetails
            default:
                return nil
            }
        }
        return nil
    }
    
    public mutating func update(value: Any?, forResponseKey responseKey: String) {
        if let suffix = responseKey.components(separatedBy: ".").last {
            switch suffix {
            case "type":
                self.type = value as? String
            case "subType":
                self.subType = value as? String
            case "accidentPictures":
                self.accidentPictures = value as? String
            case "address":
                self.address = value as? String
            case "locationInfo":
                self.locationInfo = value as? String
            case "dateOfAccident":
                self.dateOfAccident = value as? String
            case "timeOfAccident":
                self.timeOfAccident = value as? String
            case "additionalDetails":
                self.additionalDetails = value as? String

            default:
                break
            }
        }
    }
    
}
