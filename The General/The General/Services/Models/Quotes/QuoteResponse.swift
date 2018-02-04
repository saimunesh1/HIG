//
//  QuoteResponse.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

struct QuoteVehicleResponse: Decodable {
	let year: String?
	let make: String?
	let model: String?
    
    var yearMakeAndModel: String? {
        return [year, make, model].flatMap({ $0 }).joined(separator: " ")
    }
}

struct QuoteResponse: Decodable {
	let quoteNumber: String?
	let date: String?
	let status: StatusType?
	let quoteVehicles: [QuoteVehicleResponse]?

    var allowsContinuingOfApplication: Bool {
        return status == .active
    }
}
