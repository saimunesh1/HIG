//
//  CoercingDecimal.swift
//  The General
//
//  Created by Derek Bowen on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

// We need this to decode strings as decimals >_<
struct CoercingDecimal: Codable, RawRepresentable {
    let rawValue: Decimal
    
    init?(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let value = Decimal(string: stringValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid decimal string.")
        }
        
        self.rawValue = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(self.rawValue)")
    }
}
