//
//  PolicyVehicleInfoResponse.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

struct PolicyVehicleInfoResponse: Decodable {
    let year: String
    let make: String
    let model: String
}
