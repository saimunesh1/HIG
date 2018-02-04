//
//  FNOLAddressTemporary.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/16/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public struct FNOLAddressTemporary {
    
    var addressDetail1: String?
    var addressDetail2: String?
    var city: String?
    var country: String?
    var state: String?
    var street: String?
    var zip: String?
    
    
    public func titleFor(responseKey: String) -> Any? {
        if let suffix:String = responseKey.components(separatedBy: ".").last {
            return suffix.capitalizedFirst()
        }
        return nil
    }
    
    public func valueFor(responseKey: String) -> Any? {
        if let suffix = responseKey.components(separatedBy: ".").last {
            switch suffix {
            case "addressDetail1":
                return self.addressDetail1
            case "addressDetail2":
                return self.addressDetail2
            case "city":
                return self.city
            case "country":
                return self.country
            case "state":
                return self.state
            case "street":
                return self.street
            case "zip":
                return self.zip
            default:
                return nil
            }
        }
        return nil
    }
    
    public mutating func update(value: Any?, forResponseKey responseKey: String) {
        if let suffix = responseKey.components(separatedBy: ".").last {
            switch suffix {
            case "addressDetail1":
                self.addressDetail1 = value as? String
            case "addressDetail2":
                self.addressDetail2 = value as? String
            case "city":
                self.city = value as? String
            case "country":
                self.country = value as? String
            case "state":
                self.state = value as? String
            case "street":
                self.street = value as? String
            case "zip":
                self.zip = value as? String
                
            default:
                break
            }
        }
    }
    
    public func asString() -> String {
        var addressAsString = ""
        if let street = street, street.count > 0 {
            addressAsString += "\(street.lowercased().capitalized)\n"
        }
        if let addressDetail1 = addressDetail1, addressDetail1.count > 0 {
            addressAsString += "\(addressDetail1.lowercased().capitalized)\n"
        }
        if let addressDetail2 = addressDetail2, addressDetail2.count > 0 {
            addressAsString += "\(addressDetail2.lowercased().capitalized)\n"
        }
        let cityString = city ?? ""
        let stateString = state ?? ""
        let zipString = zip ?? ""
        addressAsString += "\(cityString.lowercased().capitalized)"
		if !stateString.isEmpty {
			addressAsString += ", \(stateString) \(zipString)"
		}
        return addressAsString
    }
    
    public func storeAccidentDetailsAddress() {
        if let street = self.street {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(street, displayValue: nil, forResponseKey: "accidentDetails.address.street")
        }
        if let addressDetail1 = self.addressDetail1 {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(addressDetail1, displayValue: nil, forResponseKey: "accidentDetails.address.addressDetail1")
        }
        if let addressDetail2 = self.addressDetail2 {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(addressDetail2, displayValue: nil, forResponseKey: "accidentDetails.address.addressDetail2")
        }
        if let city = self.city {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(city, displayValue: nil, forResponseKey: "accidentDetails.address.city")
        }
        if let state = self.state {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(state, displayValue: nil, forResponseKey: "accidentDetails.address.state")
        }
        if let zip = self.zip {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(zip, displayValue: nil, forResponseKey: "accidentDetails.address.zip")
        }
        if let country = self.country {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(country, displayValue: nil, forResponseKey: "accidentDetails.address.country")
        }
    }
    
    public func storeVehicleConditionLocationAddress() {
        if let street = self.street {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(street, displayValue: nil, forResponseKey: "myVehicle.vehicleConditionAndLocation.street")
        }
        if let addressDetail1 = self.addressDetail1 {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(addressDetail1, displayValue: nil, forResponseKey: "myVehicle.vehicleConditionAndLocation.addressDetail1")
        }
        if let addressDetail2 = self.addressDetail2 {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(addressDetail2, displayValue: nil, forResponseKey: "myVehicle.vehicleConditionAndLocation.addressDetail2")
        }
        if let city = self.city {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(city, displayValue: nil, forResponseKey: "myVehicle.vehicleConditionAndLocation.city")
        }
        if let state = self.state {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(state, displayValue: nil, forResponseKey: "myVehicle.vehicleConditionAndLocation.state")
        }
        if let zip = self.zip {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(zip, displayValue: nil, forResponseKey: "myVehicle.vehicleConditionAndLocation.zip")
        }
        if let country = self.country {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(country, displayValue: nil, forResponseKey: "myVehicle.vehicleConditionAndLocation.country")
        }
    }
    
   
    
    /// Populates the entity from a AddressInfo.
    ///
    /// - Parameters:
    ///   - temp: AddressInfo
    public mutating func updateFromQuestionnaire(temp: AddressInfo) -> FNOLAddressTemporary {
        self.addressDetail1 = temp.addressDetail1
        self.addressDetail2 = temp.addressDetail2
        self.city = temp.city
        self.country = temp.country
        self.state = temp.state
        self.street = temp.street
        self.zip = temp.zip
        return self
    }
}
