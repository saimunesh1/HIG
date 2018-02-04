//
//  QuotesManager.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class QuotesManager {
	typealias GetExistingQuotesClosure = (() throws -> [QuoteResponse]) -> Void
	typealias QuotesRefillMethodClosure = (() throws -> QuotesRefillUrl) -> Void

	let serviceConsumer = QuotesServiceConsumer()
	
	/// Request existing quotes
	///
	/// - Parameters:
	///  - completion: Completion handler
	func getExistingQuotes(completion: @escaping GetExistingQuotesClosure) {
		self.serviceConsumer.getExistingQuotes(completion: completion)
	}
	
	/// Requests a URL for a user to get a quote specific to their policy
	///
	/// - Parameters:
	///   - policyNumber: Account holder's policy number
	///   - completion: Completion handler
	func getQuoteRefill(forPolicy policyNumber: String, completion: @escaping QuotesRefillMethodClosure) {
		self.serviceConsumer.getQuoteRefill(forPolicy: policyNumber) { (innerClosure) in
			completion(innerClosure)
		}
	}
	
	/// Returns a URL for a user to get a quote specific to their policy
	///
	func requestANewQuoteUrlString() -> String? {
		if let urlSubstring = ApplicationContext.shared.configurationManager.configuration?.quote?.getAQuoteUrl {
			return "\(ServiceManager.shared.webContentBaseURL)\(urlSubstring)"
		}
		return nil
	}
	
	/// Returns a URL for a user to retrieve an existing quote
	///
	func retrieveAnExistingQuoteUrlString() -> String? {
		if let urlSubstring = ApplicationContext.shared.configurationManager.configuration?.quote?.retrieveAQuoteUrl {
			return "\(ServiceManager.shared.webContentBaseURL)\(urlSubstring)"
		}
		return nil
	}
	
}
