//
//  ProfileResponse.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/16/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct ProfileResponse: Decodable {
    var loginEmailAddress: String
    var policyEmailAddress: String
}

struct InsuredAddressResponse: Decodable {
    var streetAddress: String
    var city: String
    var state: String
    var zip: String
}

struct SearchAddressResponse: Decodable {
    var address: InsuredAddressResponse?
    var singleAddress: Bool
    var needsRefined: Bool
    var foundListOfAddresses: Bool
    var addressList: [RefiningAddressResponse]
}

struct RefiningAddressResponse: Decodable {
    var text: String
    var partialAddress: String
    var moniker: String
}
