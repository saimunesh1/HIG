//
//  PhoneOptionsResponse.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/17/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

enum PhoneStatusType: String, Decodable {
    case call = "C"
    case text = "T"
    case both = "B"
    case none = "D"
}

struct PhonesResponse: Decodable {
    var policyNumber: String
    var phoneOpts: [PhoneOptionsResponse]
}

struct PhoneOptionsResponse: Decodable {
    var fName: String
    var lName: String
    var middleInitial: String
    var driverNo: String
    var phoneAreaOriginal: String
    var phoneNumberOriginal: String
    var formattedOriginalPhone: String
    var preferenceOriginal: PhoneStatusType
    var primaryFlag: String
    
    enum CodingKeys: String, CodingKey {
        case fName
        case lName
        case middleInitial
        case driverNo
        case formattedOriginalPhone
        case phoneAreaOriginal
        case phoneNumberOriginal
        case preferenceOriginal
        case primaryFlag
    }
}

extension PhoneOptionsResponse {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.fName = try values.decode(String.self, forKey: .fName)
        self.lName = try values.decode(String.self, forKey: .lName)
        self.middleInitial = try values.decode(String.self, forKey: .middleInitial)
        self.driverNo = try values.decode(String.self, forKey: .driverNo)
        self.formattedOriginalPhone = try values.decode(String.self, forKey: .formattedOriginalPhone)
        self.phoneAreaOriginal = try values.decode(String.self, forKey: .phoneAreaOriginal)
        self.phoneNumberOriginal = try values.decode(String.self, forKey: .phoneNumberOriginal)
        self.preferenceOriginal = try values.decode(PhoneStatusType.self, forKey: .preferenceOriginal)
        self.primaryFlag = try values.decode(String.self, forKey: .primaryFlag)
    }
}

extension PhoneOptionsResponse {
    var isPrimary: Bool {
        return self.primaryFlag == "Y"
    }
}
