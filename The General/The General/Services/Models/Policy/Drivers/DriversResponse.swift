//
//  DriversResponse.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/5/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct DriversResponse: Decodable {
    var firstName: String
    var middleInitial: String
    var lastName: String
    var driverStatus: String
    var driverType: String
    var maritalStatus: String
    var relationToInsured: String
    var gender: String
    var occupation: String?
    var dob: Date
    var maskedLicenseNo: String?
    var licenseState: String?
    var licenseDate: String?
    var dateFirstLicenseConvert: String?
    var srFrFiling: String?
    var maskedSsn: String
    var discounts: [DriverDiscounts]?
    var violationMessage: String?
    var violations: [DriverViolations]?
}

struct DriverDiscounts: Decodable {
    var description: String
}

struct DriverViolations: Decodable {
    var occurredOn: Date
    var description: String
    var convictedOn: String
    var chargeThroughDate: Date
    var points: String
    var term: String
}
