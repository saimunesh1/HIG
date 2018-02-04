//
//  ConfigurationConsumer.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/29/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ConfigurationConsumer {
	typealias GetConfigurationClosure = (() throws -> ConfigurationResponse) -> Void
	
	let serviceManager = ServiceManager.shared
	
	/// Request the proxyKillSwitch configuration info
	///
	/// - Parameters:
	///  - completion: Completion handler
	func getConfiguration(completion: @escaping GetConfigurationClosure) {
		let request = self.serviceManager.request(type: .get, path: "/rest/proxyKillSwitch/appConfig/iOS", headers: nil, body: nil)
		self.serviceManager.async(request: request) { (innerClosure) in
			do {
				let response = try innerClosure()
				if let jsonData = response.data {
					let responseModel = try JSONDecoder().decode(ConfigurationResponse.self, from: jsonData)
					completion({ return responseModel })
				}
			} catch let error {
				completion({ throw error })
			}
		}
	}
	

}
