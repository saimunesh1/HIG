//
//  ConfigurationResponse.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/29/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

struct ConfigRegistrationResponse: Decodable {
	let registrationUrl: String?
}

struct ConfigQuoteResponse: Decodable {
	let getAQuoteUrl: String?
	let retrieveAQuoteUrl: String?
	let useSso: Bool
}

struct ConfigPaymentResponse: Decodable {
	let payNearMeMinimumEnabledVersion: String?
}

struct ConfigClaimResponse: Decodable {
	let allowFnolImages: Bool?
}

struct ConfigDayResponse: Decodable {
	let dayName: String?
	let phoneHoursStart: String?
	let phoneHoursEnd: String?
	let timeZone: String?
}

struct ConfigHolidayDetailsResponse: Decodable {
	let year: Int
	let holidays: [String]?
}

struct ConfigCustomerServiceResponse: Decodable {
	let name: String?
	let minimumEnabledVersion: String?
	let days: [ConfigDayResponse]?
	let holidayDetails: [ConfigHolidayDetailsResponse]?
}

struct ConfigAppsResponse: Decodable {
	let name: String?
	let minimumEnabledVersion: String?
}

struct ConfigurationResponse: Decodable {
	let os: String?
	let message: String?
	let success: Bool?
	let registration: ConfigRegistrationResponse?
	let quote: ConfigQuoteResponse?
	let payment: ConfigPaymentResponse?
	let claim: ConfigClaimResponse?
	let customerServices: [ConfigCustomerServiceResponse]?
	let apps: [ConfigAppsResponse]?
}
