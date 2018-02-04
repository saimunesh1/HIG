//
//  JSONDecoder+Shared.swift
//  The General
//
//  Created by Derek Bowen on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

extension JSONDecoder {
    static var shared: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.dataDecodingStrategy = .base64
        
        return decoder
    }()
}
