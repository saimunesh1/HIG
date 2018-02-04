//
//  HistoricalDocumentRequest.swift
//  The General
//
//  Created by Leif Harrison on 12/7/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

struct HistoricalDocumentRequest: Encodable {
    var pdfName: String
    var startPage: UInt
    var endPage: UInt
    var detailKey: String
}
