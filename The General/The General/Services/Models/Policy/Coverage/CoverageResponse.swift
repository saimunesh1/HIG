//
//  CoverageResponse.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/5/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct CoverageResponse: Decodable {
    var coveragePolicy: CoveragePolicy
    var discountMessage: String?
    var discounts: [DiscountTypes]
    var coverages: [CoverageTypes]
}

struct CoveragePolicy: Decodable {
    var originalEffectiveDate: Date
    var effectiveDate: Date
    var expirationDate: Date
    var payPlan: String
}

struct DiscountTypes: Decodable {
    var description: String
    var level: String
}

struct CoverageTypes: Decodable {
    var description: String
    var deductible: String
    var limits: String
}
