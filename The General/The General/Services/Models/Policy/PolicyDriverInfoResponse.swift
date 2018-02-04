//
//  PolicyDriverInfoResponse.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

struct PolicyDriverInfoResponse: Decodable {
    let firstName: String
    let lastName: String
    let middleInitial: String?
}
