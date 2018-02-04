//,
//  FNOLClaim+CoreDataClass.swift
//  The General
//
//  Created by Derek Bowen on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import UIKit
import CoreData
import MagicalRecord

public enum YesNoUnsure: String {
    case yes = "Yes"
    case no = "No"
    case unsure = "Unsure"
    static let allValues = [yes.rawValue, no.rawValue, unsure.rawValue]
}

public enum YesNoIDontKnow: String {
    case yes = "Yes"
    case no = "No"
    case i_dont_know = "I don't know"
    static let allValues = [yes.rawValue, no.rawValue, i_dont_know.rawValue]
}

public enum AddressType {
	case accidentLocation
	case vehiclelocation
}

@objc(FNOLClaim)
public class FNOLClaim: NSManagedObject {
    /// Generates a new UUID for the claim if one doesn't exist already
    func generateLocalIdIfNeeded() {
        guard self.localId == nil else { return }
        self.localId = UUID().uuidString
    }
    
    /// - Relationships
    var responsesArray: [FNOLResponse]? {
        return self.responses?.allObjects as? [FNOLResponse]
    }
    
    var imagesArray: [FNOLImage]? {
        return self.images?.array as? [FNOLImage]
    }
    
    var damagedPartsArray: [FNOLDamagedPart]? {
        return self.damagedParts?.array as? [FNOLDamagedPart]
    }
}

// MARK: - Responses
extension FNOLClaim {
	
    /// Create or update value associated with the response key.
    ///
    /// - Parameters:
	///   - value: Value
    ///   - displayValue: Display value (used only for populating UI with values user has selected)
    ///   - responseKey: Response key
	func setValue(_ value: String, displayValue: String?, forResponseKey responseKey: String) {
        // Get response object associated with claim/responseKey
        var response: FNOLResponse? = self.responsesArray?.filter({ $0.responseKey == responseKey }).first
        if let response = response {
            response.value = value
			response.displayValue = displayValue
        }
        else { // Not found, create a new one.
            response = FNOLResponse.mr_createEntity()
            response?.responseKey = responseKey
            response?.value = value
			response?.displayValue = displayValue
            self.addToResponses(response!)
        }
    }
    
    /// Get value associated with the response key.
    ///
    /// - Parameter responseKey: Response key
    /// - Returns: Value for response key
    func value(forResponseKey responseKey: String) -> String? {
        // Get response object associated with claim/responseKey
        let response: FNOLResponse? = self.responsesArray?.filter({ $0.responseKey == responseKey }).first
        
        return response?.value
    }
	
	/// Get display value associated with the response key (for display in UI).
	///
	/// - Parameter responseKey: Response key
	/// - Returns: Display value for response key
	func displayValue(forResponseKey responseKey: String) -> String? {
		// Get response object associated with claim/responseKey
		let response: FNOLResponse? = self.responsesArray?.filter({ $0.responseKey == responseKey }).first
		
		return response?.displayValue
	}
}


// MARK: - Images

extension FNOLClaim {
    /// Add additional image associated with a responseKey
    ///
    /// - Parameters:
    ///   - image: Image
    ///   - responseKey: Response key
    func addImage(_ image: UIImage, forResponseKey responseKey: String) {
        let moImage: FNOLImage = FNOLImage.mr_createEntity()!
        moImage.generateImageIdIfNeeded()
        moImage.responseKey = responseKey
        moImage.image = image
		moImage.thumbnailImage = image.resizedTo(shortestSide: 480.0)
        moImage.claim = self
    }
    
    /// Create's or updates the first image object found matching the response key.
    /// Intended for places where only 1 image is allowed.
    ///
    /// - Parameters:
    ///   - image: Image
    ///   - responseKey: Response key
    func setImage(_ image: UIImage, forResponseKey responseKey: String) {
        // Get first image object associated with claim/responseKey
        let moImage = self.images(forResponseKey: responseKey)?.first
        
        if let moImage = moImage {
            moImage.image = image
        } // Not found, create a new one.
        else {
            self.addImage(image, forResponseKey: responseKey)
        }
    }
    
    /// Get images associated with a response key
    ///
    /// - Parameter responseKey: Response key
    /// - Returns: Array of images
    func images(forResponseKey responseKey: String) -> [FNOLImage]? {
        return self.imagesArray?.filter({ $0.responseKey ?? "" == responseKey })
    }
    
    /// Human readable size of the all the images added together
    var sizeOfImages: String {
        var size: Int64 = 0
        
        if let images = self.imagesArray {
            size = images.map({ $0.imageSize }).reduce(0, + )
        }
        
        return ByteCountFormatter.file.string(fromByteCount: size)
    }
}

extension FNOLClaim {
	
    /// Add damageParts with Image
    ///
    /// - Parameter responseKey: Response key
    /// - Returns: Array of images
    func addDamagePart(partCode: String, damagePhoto: UIImage?) {
        guard let parts = damagedParts(forResponseKey: partCode) else {
            return
        }
        
        if let moDamagedPart = parts.first {
            if damagePhoto != nil {
                addDamagedImage(image: damagePhoto, toDamgePart: moDamagedPart)
            }
        }
        else {
            let moDamagePart = FNOLDamagedPart.mr_createEntity()
            moDamagePart?.claim = self
            moDamagePart?.code = partCode
            //Damaged part can be without image too
            if damagePhoto != nil {
                addDamagedImage(image: damagePhoto, toDamgePart: moDamagePart!)
            }
        }
    }
    
    /// Add UIImage to damagedPart
    ///
    /// - Parameter responseKey: Response key
    /// - Returns: mo image
    func addDamagedImage(image: UIImage?, toDamgePart: FNOLDamagedPart) {
        let moImage = FNOLImage.mr_createEntity()
        moImage?.generateImageIdIfNeeded()
        moImage?.image = image
        moImage?.damagedPart = toDamgePart
        moImage?.claim = self
    }
    
    /// get images from damagedPart
    ///
    /// - Parameter responseKey: Response key
    /// - Returns: Array of mo Images
    func imagesForDamagedPart(forCode: String) -> [FNOLImage]? {
        guard let parts = damagedParts(forResponseKey: forCode) else {
            return []
        }
        return parts.filter({$0.code! == forCode}).first?.imagesArray
    }
    
    /// Add UIImage to damagedPart
    ///
    /// - Parameter responseKey: Response key
    /// - Returns: mo Damaged Part
    func damagedParts(forResponseKey responseKey: String) -> [FNOLDamagedPart]? {
        return self.damagedParts?.filter({ ($0 as! FNOLDamagedPart).code ?? "" == responseKey }) as? [FNOLDamagedPart]
    }
}


// MARK: - FNOLPeople

extension FNOLClaim {
	
	/// Add person to claim
	///
	/// - Parameters:
	///   - person: FNOLPerson
	func addPerson(_ person: FNOLPerson) {
		if var existingPeople = people?.allObjects as? [FNOLPerson] {
			person.claim = self
			if let _ = existingPeople.first(where: { $0 == person }) {
				// Person already exists on claim; do nothing
			} else {
				existingPeople.append(person)
				people = Set(existingPeople) as NSSet
			}
		}
	}

}


// MARK: - FNOLVehicle

extension FNOLClaim {
	
	/// Add vehicle to claim
	///
	/// - Parameters:
	///   - vehicle: FNOLVehicle
	func addVehicle(_ vehicle: FNOLVehicle) {
		let existingVehicles = vehicles?.mutableCopy() as! NSMutableOrderedSet
		vehicle.claim = self
		if let _ = existingVehicles.first(where: { ($0 as! FNOLVehicle) == vehicle }) {
			// Vehicle already exists on claim; do nothing
		} else {
			existingVehicles.add(vehicle)
			vehicles = existingVehicles.copy() as? NSOrderedSet
		}
	}
	
}

// MARK: - Addresses

extension FNOLClaim {
	
	public func addressAsString(addressType: AddressType) -> String {
		var addressAsString = ""
		let prefix = (addressType == .accidentLocation) ? "accidentDetails.address" : "myVehicle.vehicleConditionAndLocation"
		if let street = self.value(forResponseKey: "\(prefix).street"), street.count > 0 {
			addressAsString += "\(street.lowercased().capitalized)\n"
		}
		if let addressDetail1 = self.value(forResponseKey: "\(prefix).addressDetail1"), addressDetail1.count > 0 {
			addressAsString += "\(addressDetail1.lowercased().capitalized)\n"
		}
		if let addressDetail2 = self.value(forResponseKey: "\(prefix).addressDetail2"), addressDetail2.count > 0 {
			addressAsString += "\(addressDetail2.lowercased().capitalized)\n"
		}
		let cityString = self.value(forResponseKey: "\(prefix).city") ?? ""
		let stateString = self.value(forResponseKey: "\(prefix).state") ?? ""
		let zipString = self.value(forResponseKey: "\(prefix).zip") ?? ""
		addressAsString += "\(cityString.lowercased().capitalized)"
		if !stateString.isEmpty {
			addressAsString += ", \(stateString) \(zipString)"
		}
		return addressAsString
	}
	
}
