//
//  EsignResponse.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/18/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct EsignResponse: Decodable {
    var url: String
    var needsEsign: Bool
}
