//
//  PaymentsGenerateTokenRequest.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

struct GenerateTokenRequest: Encodable {
    let policyNumber: String
    let cardNumber: String
    let month: UInt
    let year: UInt
    let firstName: String
    let lastName: String
    let street: String
    let city: String
    let state: String
    let zip: String
}
