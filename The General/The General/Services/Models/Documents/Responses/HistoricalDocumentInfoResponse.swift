//
//  HistoricalDocumentInfoResponse.swift
//  The General
//
//  Created by Leif Harrison on 12/7/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

struct HistoricalDocumentInfoResponse: Decodable {
    let pdfName: String
    let startPage: UInt
    let endPage: UInt
    let detailKey: String
}
