//
//  IDCardProofResponse.swift
//  The General
//
//  Created by Hopkinson, Todd (US - Denver) on 1/11/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct IDCardProofResponse: Decodable {
    let message: String?
    let success: Bool?
    let pdfBase64: String?
}
