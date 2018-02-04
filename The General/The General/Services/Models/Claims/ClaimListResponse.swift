//
//  ClaimListResponse.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/12/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

struct ClaimEntry: Decodable {
	let claimNumber: String?
	let status: String?
	let lossCause: String?
	let lossCity: String?
	let lossState: String?
	let dateOfLoss: String?
	let nextStepTitle: String?
	let nextStepDescription: String?
	let referenceNumber: Int?
}

struct ClaimListResponse: Decodable {
	let claims: [ClaimEntry]?
}
