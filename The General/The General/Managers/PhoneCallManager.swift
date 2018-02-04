//
//  PhoneCallManager.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public struct PhoneNumber {
	let number: String
	let displayNumber: String
}

class PhoneCallManager {
	
    public let claimsNumber = PhoneNumber(number: "18002801466,3", displayNumber: "1-800-280-1466 #3")
	public let customerServiceNumber = PhoneNumber(number: "18883332331", displayNumber: "1-888-333-2331")
	public let getAQuoteNumber = PhoneNumber(number: "18005561030", displayNumber: "1-800-556-1030")
    public let salesNumber = PhoneNumber(number: "18443280306", displayNumber: "1-844-328-0306")
    public let roadsideAssistanceNumber = PhoneNumber(number: "18007455791", displayNumber: "1-800-745-5791")

	public func callClaimsNumber() {
		callNumber(phoneNumber: claimsNumber.number)
	}

	public func callCustomerServiceNumber() {
		callNumber(phoneNumber: customerServiceNumber.number)
	}
	
	public func callGetAQuoteNumber() {
		callNumber(phoneNumber: getAQuoteNumber.number)
	}
	
	public func callSalesNumber() {
		callNumber(phoneNumber: salesNumber.number)
	}

    public func callRoadsideAssistance() {
        callNumber(phoneNumber: roadsideAssistanceNumber.number)
    }
    
	private func callNumber(phoneNumber: String) {
		if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
			let application = UIApplication.shared
			if (application.canOpenURL(phoneCallURL)) {
				application.open(phoneCallURL, options: [:], completionHandler: nil)
			}
		}
	}

}
