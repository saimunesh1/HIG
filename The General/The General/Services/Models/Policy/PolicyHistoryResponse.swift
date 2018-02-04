//
//  PolicyHistoryResponse.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/22/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct PolicyHistoryResponse: Decodable {
    var description: String?
    var amount: String?
    var yearNoticed: String?
    var noticedOn: Date?
    var effectiveDate: Date?
}
