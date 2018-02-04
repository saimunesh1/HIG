//
//  SupportManager.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/4/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

class SupportManager {

	let serviceConsumer = SupportServiceConsumer()
	
	/// Request a list of call-back hours
	///
	/// - Parameters:
	///  - completion: Completion handler
	func requestCallCenterHours(completion: @escaping CallCenterSchedulingSettingsClosure) {
		serviceConsumer.requestCallCenterHours(completion: completion)
	}
	
	/// Request a list of call-back windows for the current date
	///
	/// - Parameters:
	///  - type: Support call type (claims, customer service, sales)
	///  - completion: Completion handler
	func requestCallBackTimeWindows(type: SupportCallType, completion: @escaping CallBackScheduleClosure) {
		serviceConsumer.requestCallBackTimeWindows(type: type, completion: completion)
	}
	
	/// Request a call back
	///
	/// - Parameters:
	///  - completion: Completion handler
	func requestCallBack(type: SupportCallType, number: String, time: Date?, completion: @escaping RequestCallBackClosure) {
		serviceConsumer.requestCallBack(type: type, number: number, time: time, completion: completion)
	}
	
	/// Get current status of a call back
	///
	/// - Parameters:
	///  - sid: Call back ID
	///  - completion: Completion handler
	func getCallBackStatus(sid: String, completion: @escaping CallBackStatusClosure) {
		serviceConsumer.getCallBackStatus(sid: sid, completion: completion)
	}

	/// Cancel a call back
	///
	/// - Parameters:
	///  - sid: Call back ID
	///  - completion: Completion handler
	func cancelCallBack(sid: String, completion: @escaping CancelCallBackClosure) {
		serviceConsumer.cancelCallBack(sid: sid, completion: completion)
	}

}
