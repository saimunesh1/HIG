//
//  VehicleResponse.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/5/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct VehicleResponse: Decodable {
    var vehicleNumber: String
    var year: String
    var premium: String
    var description: String
    var status: String
    var vin: String
    var licensePlate: String?
    var compCollisionDesc: String
    var compCollisionDescLabel: String
    var mileage: String
    var leased: String
    var owner: String?
    var coOwner: String?
    var vehicleCoveragesMessage: String?
    var vehicleCoverages: [VehicleCoverages]
    var discounts: [VehicleDiscounts]?
    var lienholders: [VehicleLeinHolders]?
}

struct VehicleCoverages: Decodable {
    var description: String
    var deductible: String
    var premium: String
}

struct VehicleDiscounts: Decodable {
    var description: String
}

struct VehicleLeinHolders: Decodable {
    var type: String
    var dateAdded: Date
    var dateDeleted: String?
    var name: String
    var address: String
    var city: String
    var state: String
    var zip: String
}
