//
//  QuotesServiceConsumer.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

class QuotesServiceConsumer {
    typealias GetExistingQuotesClosure = (() throws -> [QuoteResponse]) -> Void
	typealias QuotesRefillClosure = (() throws -> QuotesRefillUrl) -> Void

	let serviceManager = ServiceManager.shared
    
    /// Request existing quotes
    ///
    /// - Parameters:
    ///  - completion: Completion handler
    func getExistingQuotes(completion: @escaping GetExistingQuotesClosure) {
        if let tgt = SessionManager.accessToken {
            let request = self.serviceManager.request(type: .get, path: "/rest/quote/listQuotes/\(tgt)", headers: nil, body: nil)
            self.serviceManager.async(request: request) { (innerClosure) in
                do {
                    let response = try innerClosure()
                    guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                        completion({ throw JSONErrorType.parsingError })
                        return
                    }
                    
                    if let quotes = responseData["quotes"] as? [[String: Any]] {
                        let jsonData = try JSONSerialization.data(withJSONObject: quotes, options: [])
                        let responseModel = try JSONDecoder().decode([QuoteResponse].self, from: jsonData)
                        completion({ return responseModel })
                    }
                    else {
                        completion({ return [] })
                    }
                } catch let error {
                    completion({ throw error })
                }
            }
        }
    }
	
	/// Requests a URL for a user to get a quote specific to their policy
	///
	/// - Parameters:
	///   - policyNumber: Account holder's policy number
	///   - completion: Completion handler
	func getQuoteRefill(forPolicy policyNumber: String, completion: @escaping QuotesRefillClosure) {
		let request = self.serviceManager.request(type: .get, path: "/rest/refill/generateRefillRequest/\(policyNumber)", headers: nil, body: nil)
		self.serviceManager.async(request: request) { (innerClosure) in
			do {
				let response = try innerClosure()
				guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
					completion({ throw JSONErrorType.missingElement })
					return
				}
				let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
				let responseModel = try JSONDecoder.shared.decode(QuotesRefillUrl.self, from: jsonData)
				completion({ return responseModel })
			} catch {
				completion({ throw error })
			}
		}
	}

}
