//
//  GetTokenResponse.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

struct GetTokenResponse: Decodable {
    let policyNumber: String?
    let quotes: [String]?
    let tgt: String
}
