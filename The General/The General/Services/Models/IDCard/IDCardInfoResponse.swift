//
//  IDCardInfoResponse.swift
//  The General
//
//  Created by Hopkinson, Todd (US - Denver) on 1/4/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct IDCardVehiclesResponse: Decodable {
    let vehicleNumber: String?
    let make: String?
    let model: String?
    let year: String?
    let vin: String?
}

struct IDCardDriversResponse: Decodable {
    let driverNumber: String?
    let driverName: String?
    let gender: String?
    let licenseNumber: String?
}

struct IDCardPolicyDataResponse: Decodable {
    let policyNumber: String?
    let active: Bool?
    let drivers: [IDCardDriversResponse]?
    let vehicles: [IDCardVehiclesResponse]?
}

struct IDCardInfoResponse: Decodable {
    let message: String?
    let success: Bool?
    let data: IDCardPolicyDataResponse?
    
    var jsonDataCacheBase64String: String?
}

extension IDCardInfoResponse {
    
    func cards() -> [IDCard] {
        guard let data = self.data else { return [] }
        guard let drivers = data.drivers else { return [] }
        guard let vehicles = data.vehicles else { return [] }
        
        var idCards = [IDCard]()
        
        drivers.forEach { (driver) in
            vehicles.forEach({ (vehicle) in
                if  let driverName = driver.driverName,
                    let make = vehicle.make,
                    let model = vehicle.model,
                    let year = vehicle.year,
                    let vin = vehicle.vin {
                        idCards.append(IDCard(driverName: driverName, make: make, model: model, year: year, vin: vin))
                }
            })
        }
        
        return idCards
    }
    
    var vehicleCount: Int {
        return data?.vehicles?.count ?? 0
    }
    
    var driverCount: Int {
        return data?.drivers?.count ?? 0
    }
    
    /// Reintegrates id cards in the form of an IDCardInfoRepsonse from a cached jsonData base64 string parameter
    ///
    /// Parameters:
    ///     jsonDataCacheBase64String: string from jsonData used to generate an IDCardInfoResponse
    static func idCardInforResponseFromCache(jsonDataCacheBase64String: String) -> IDCardInfoResponse? {
        if let jsonData = Data.init(base64Encoded: jsonDataCacheBase64String) {
            do {
                let responseModel = try JSONDecoder().decode(IDCardInfoResponse.self, from: jsonData)
                return responseModel
            } catch let error {
                print("Error decoding cached id card data into IDCardInfoResponse: \(error)")
            }
        }
        return nil
    }
}

struct IDCard {
    let driverName: String
    let make: String
    let model: String
    let year: String
    let vin: String
}
