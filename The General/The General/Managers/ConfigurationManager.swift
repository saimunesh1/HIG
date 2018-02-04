//
//  ConfigurationManager.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/29/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation
import MagicalRecord

class ConfigurationManager {
	
	typealias GetConfigurationClosure = (() throws -> Void) -> Void
	
	public var configuration: ConfigurationResponse?
	private let configurationConsumer = ConfigurationConsumer()
	
	/// Requests the configuration from proxyKillSwitch
	///
	/// - Parameters:
	///   - completion: Completion block
	func getConfiguration(completion: @escaping GetConfigurationClosure) {
		
		self.configurationConsumer.getConfiguration() { (innerClosure) in
			do {
				let responseModel = try innerClosure()
				self.configuration = responseModel
                
                completion({ })
			}
			catch {
				completion({ throw error })
			}
		}
	}
	
	/// Indicates whether a given date is on a call-center holiday.
	/// Not applicable to call-backs.
	///
	public func isCallCenterHoliday(date: Date) -> Bool {
		guard let configuration = configuration, let customerServices = configuration.customerServices else { return false }
		guard let fonolo = customerServices.first(where: { $0.name == "fonolo" }), let holidayResponses = fonolo.holidayDetails else { return false }
		let dateFormatter = DateFormatter.holidayDate
		for holidayResponse in holidayResponses {
			if let holidays = holidayResponse.holidays {
				for holiday in holidays {
					if let holidayDate = dateFormatter.date(from: holiday) {
						if NSCalendar.current.isDate(holidayDate, inSameDayAs: date) {
							return true
						}
					}
				}
			}
		}
		return false
	}
	
	/// Returns the current start and end times for phone and chat availability.
	///
	public func callTheGeneralAndChatHours() -> (startTime: Date, endTime: Date, timeZone: String)? {
		guard let fonolo = ApplicationContext.shared.configurationManager.configuration?.customerServices?.filter({ $0.name == "fonolo" }).first else { return nil }
		guard let days = fonolo.days else { return nil }
		guard let day = days.first(where: { $0.dayName == Date().weekdayNameForCallBackTimeWindows() }) else { return nil }
		guard let timeZoneString = day.timeZone else { return nil }
		guard let sourceTimeZone = NSTimeZone.init(name: timeZoneString) else { return nil }
		guard let phoneHoursStartString = day.phoneHoursStart else { return nil }
		guard let phoneHoursEndString = day.phoneHoursEnd else { return nil }

		// Assign today's date to time value and make sure dates are in GMT
		let dateFormatter = DateFormatter.hoursMilitary
		dateFormatter.timeZone = sourceTimeZone as TimeZone
		guard let phoneHoursStartTime = dateFormatter.date(from: phoneHoursStartString)?.withTodaysYearMonthDay() else { return nil }
		guard let phoneHoursEndTime = dateFormatter.date(from: phoneHoursEndString)?.withTodaysYearMonthDay() else { return nil }
		return (phoneHoursStartTime, phoneHoursEndTime, timeZoneString)
	}

}
