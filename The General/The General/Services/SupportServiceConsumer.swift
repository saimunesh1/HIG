//
//  SupportServiceConsumer.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/4/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

typealias CallCenterSchedulingSettingsClosure = (() throws -> CallCenterSchedulingSettingsResponse) -> Void
typealias CallBackScheduleClosure = (() throws -> CallBackSchedulesResponse) -> Void
typealias RequestCallBackClosure = (() throws -> RequestCallBackResponse) -> Void
typealias CallBackStatusClosure = (() throws -> CallBackStatusResponse) -> Void
typealias CancelCallBackClosure = (() throws -> Void) -> Void

class SupportServiceConsumer {
	
	let serviceManager = ServiceManager.shared
	let fonoloAccountSID = "AC5266a206c1d692aa873b415e38712f98"
	let fonoloAuthToken = "27235e4fe4cc39f04e8f171a99e7ae3ef75c88efd96e6f335e8f5658d7d46ec7"
	let fonoloUrlString = "https://api.fonolo.com/3.0/callback"
	
	/// Create a Fonolo URLRequest
	///
	/// - Parameters:
	///  - urlString: URL as String
	private func fonoloRequest(urlString: String) -> URLRequest? {
		if let url = URL(string: urlString) {
			let loginString = "\(fonoloAccountSID):\(fonoloAuthToken)"
			let loginData = loginString.data(using: String.Encoding.utf8)!
			let base64LoginString = loginData.base64EncodedString()
			var request = URLRequest(url: url)
			request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
			return request
		}
		return nil
	}
	
	/// Request a list of call-back hours
	///
	/// - Parameters:
	///  - completion: Completion handler
	func requestCallCenterHours(completion: @escaping CallCenterSchedulingSettingsClosure) {
		let profileSid = ServiceManager.shared.fonoloProfileSid
		let urlString = "https://api.fonolo.com/3.0/profile/\(profileSid)/scheduling"
		if let request = fonoloRequest(urlString: urlString) {
			serviceManager.async(request: request) { (innerClosure) in
				do {
					let response = try innerClosure()
					guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
						completion({ throw JSONErrorType.parsingError })
						return
					}
					let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
					let responseModel = try JSONDecoder().decode(CallCenterSchedulingSettingsResponse.self, from: jsonData)
					completion({ return responseModel })
				} catch let error {
					completion({ throw error })
				}
			}
		}
	}
	
	/// Request a list of call-back windows for the current date
	///
	/// - Parameters:
	///  - type: Support call type (claims, customer service, sales)
	///  - completion: Completion handler
	func requestCallBackTimeWindows(type: SupportCallType, completion: @escaping CallBackScheduleClosure) {
		let profileSid = ServiceManager.shared.fonoloProfileSid
		var optionSid: String?
		switch type {
		case .customerService: optionSid = ServiceManager.shared.fonoloOptionCustomerServiceSid
		case .sales: optionSid = ServiceManager.shared.fonoloOptionSalesSid
		default: break
		}
		if let optionSid = optionSid {
			let urlString = "https://api.fonolo.com/3.0/profile/\(profileSid)/option/\(optionSid)/schedule"
			if let request = fonoloRequest(urlString: urlString) {
				serviceManager.async(request: request) { (innerClosure) in
					do {
						let response = try innerClosure()
						guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
							completion({ throw JSONErrorType.parsingError })
							return
						}
						let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
						let responseModel = try JSONDecoder().decode(CallBackSchedulesResponse.self, from: jsonData)
						completion({ return responseModel })
					} catch let error {
						completion({ throw error })
					}
				}
			}
		}
	}

	/// Request a call back
	///
	/// - Parameters:
	///  - type: Support call type (claims, customer service, sales)
	///  - number: The number the call should come to
	///  - time: Call back time
	///  - completion: Completion handler
	func requestCallBack(type: SupportCallType, number: String, time: Date?, completion: @escaping RequestCallBackClosure) {
		guard var request = fonoloRequest(urlString: "https://api.fonolo.com/3.0/callback") else { return }
		request.httpMethod = "POST"
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		let dateFormatter = DateFormatter.callbackDateFormatter
		guard let (_, _, timeZoneString) = ApplicationContext.shared.configurationManager.callTheGeneralAndChatHours() else { return }
		dateFormatter.timeZone = TimeZone(abbreviation: timeZoneString)
		var fcStartDate: String?
		if let time = time {
			fcStartDate = dateFormatter.string(from: time).replacingOccurrences(of: " ", with: "%20")
		}
		var fcOption: String?
		switch type {
		case .customerService: fcOption = ServiceManager.shared.fonoloOptionCustomerServiceSid
		case .sales: fcOption = ServiceManager.shared.fonoloOptionSalesSid
		default: break
		}
		print(fcStartDate ?? "")
		if let fcOption = fcOption {
			var bodyData = "fc_number=\(number)&fc_option=\(fcOption)"
			if let date = fcStartDate {
				bodyData += "&fc_start_date=\(date)"
			}
			request.httpBody = bodyData.data(using: String.Encoding.utf8)
			serviceManager.async(request: request) { (innerClosure) in
				do {
					let response = try innerClosure()
					guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
						completion({ throw JSONErrorType.parsingError })
						return
					}
					let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
					let responseModel = try JSONDecoder().decode(RequestCallBackResponse.self, from: jsonData)
					completion({ return responseModel })
				} catch let error {
					completion({ throw error })
				}
			}
		}
	}

	/// Get current status of a call back
	///
	/// - Parameters:
	///  - sid: Call back ID
	///  - completion: Completion handler
	func getCallBackStatus(sid: String, completion: @escaping CallBackStatusClosure) {
		let r = fonoloRequest(urlString: fonoloUrlString + "/\(sid)/status")
		guard var request = r else { return }
		request.httpMethod = "GET"
		serviceManager.async(request: request) { (innerClosure) in
			do {
				let response = try innerClosure()
				guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
					completion({ throw JSONErrorType.parsingError })
					return
				}
				let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
				let responseModel = try JSONDecoder().decode(CallBackStatusResponse.self, from: jsonData)
				completion({ return responseModel })
			} catch let error {
				completion({ throw error })
			}
		}
	}
	
	/// Cancel a call back
	///
	/// - Parameters:
	///  - sid: Call back ID
	///  - completion: Completion handler
	func cancelCallBack(sid: String, completion: @escaping CancelCallBackClosure) {
		let r = fonoloRequest(urlString: fonoloUrlString + "/\(sid)/cancel")
		guard var request = r else { return }
		request.httpMethod = "POST"
		serviceManager.async(request: request) { (innerClosure) in
			do {
				let _ = try innerClosure() // No meaningful body in the response
				completion({ return })
			} catch {
				completion({ throw error })
			}
		}
	}
	
}
