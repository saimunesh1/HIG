//
//  ClaimAdjusterResponse.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/19/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

struct ClaimAdjuster: Decodable {
	let name: String?
	let phoneNumber: String?
	let `extension`: String?
	let emailAddress: String?
	let primary: Bool?
	let coverageType: String?
}

struct ClaimAdjusterResponse: Decodable {
	let adjusters: [ClaimAdjuster]?
}
