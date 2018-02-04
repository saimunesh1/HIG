//
//  ClaimsManager.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/13/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsManager {
	
	let serviceManager = ServiceManager.shared
	lazy var serviceConsumer = ClaimsServiceConsumer()
	
	/// Request existing claims for policy
	///
	/// - Parameters:
	///  - policyNumber: Policy number
	///  - completion: Completion handler
	func getClaims(forPolicy policy: String, completion: @escaping ClaimsClaimListClosure) {
		serviceConsumer.getClaims(forPolicy: policy, completion: completion)
	}

	/// Request a specific claim
	///
	/// - Parameters:
	///  - claimId: Claim ID
	///  - completion: Completion handler
	func getClaim(claimId: String, completion: @escaping ClaimsClaimClosure) {
		serviceConsumer.getClaim(claimId: claimId, completion: completion)
	}
	
	/// Requests the list of adjusters for a given claim
	///
	/// - Parameters:
	///   - claimId: Claim ID
	///   - completion: Completion handler
	func getAdjusterList(claimId: String, completion: @escaping ClaimsAdjusterListClosure) {
		serviceConsumer.getAdjusterList(claimId: claimId, completion: completion)
	}

}
