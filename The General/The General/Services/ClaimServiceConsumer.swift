//
//  ClaimServiceConsumer.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/12/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

typealias ClaimsClaimClosure = (() throws -> ClaimResponse) -> Void
typealias ClaimsClaimListClosure = (() throws -> ClaimListResponse) -> Void
typealias ClaimsAdjusterListClosure = (() throws -> ClaimAdjusterResponse) -> Void

class ClaimsServiceConsumer {

	let serviceManager = ServiceManager.shared
	
	/// Requests all claims for a policy
	///
	/// - Parameters:
	///   - policyNumber: Policy number
	///   - completion: Completion handler
	func getClaims(forPolicy policyNumber: String, completion: @escaping ClaimsClaimListClosure) {
		let request = self.serviceManager.request(type: .get, path: "/rest/claims/getClaimList/\(policyNumber)", headers: nil, body: nil)
		self.serviceManager.async(request: request) { (innerClosure) in
			do {
				let response = try innerClosure()
				guard let json = response.jsonObject, let responseData = (json["data"] as? [String: Any]) else {
					completion({ throw JSONErrorType.missingElement })
					return
				}
				let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
				let responseModel = try JSONDecoder.shared.decode(ClaimListResponse.self, from: jsonData)
				completion({ return responseModel })
			} catch {
				completion({ throw error })
			}
		}
	}

	
	/// Requests a claim
	///
	/// - Parameters:
	///   - claimId: Claim ID
	///   - completion: Completion handler
	func getClaim(claimId: String, completion: @escaping ClaimsClaimClosure) {
		let request = self.serviceManager.request(type: .get, path: "/rest/claims/getClaimInformation/\(claimId)", headers: nil, body: nil)
		self.serviceManager.async(request: request) { (innerClosure) in
			do {
				let response = try innerClosure()
				guard let json = response.jsonObject, let responseData = (json["data"] as? [String: Any]) else {
					completion({ throw JSONErrorType.missingElement })
					return
				}
				let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
				let responseModel = try JSONDecoder.shared.decode(ClaimResponse.self, from: jsonData)
				completion({ return responseModel })
			} catch {
				completion({ throw error })
			}
		}
	}
	
	/// Requests the list of adjusters for a given claim
	///
	/// - Parameters:
	///   - claimId: Claim ID
	///   - completion: Completion handler
	func getAdjusterList(claimId: String, completion: @escaping ClaimsAdjusterListClosure) {
		let request = self.serviceManager.request(type: .get, path: "/rest/claims/getAdjusterInformation/\(claimId)", headers: nil, body: nil)
		self.serviceManager.async(request: request) { (innerClosure) in
			do {
				let response = try innerClosure()
				guard let json = response.jsonObject, let responseData = (json["data"] as? [String: Any]) else {
					completion({ throw JSONErrorType.missingElement })
					return
				}
				let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
				print(json)
				let responseModel = try JSONDecoder.shared.decode(ClaimAdjusterResponse.self, from: jsonData)
				completion({ return responseModel })
			} catch {
				completion({ throw error })
			}
		}
	}
	
}
