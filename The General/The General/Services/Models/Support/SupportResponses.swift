//
//  SupportResponses.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/4/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct RequestCallBackResponse: Decodable {
	let sid: String?
	let status: String?
}

struct CallBackStatusResponse: Decodable {
	let sid: String?
	let startDate: String?
	let status: String?
	let duration: Int?
	let details: String?
	
	private enum CodingKeys: String, CodingKey {
		case sid, startDate = "start_date", status, duration, details
	}
}

struct CallBackTimeWindowResponse: Decodable {
	let startTime: String?
	let endTime: String?
	
	private enum CodingKeys: String, CodingKey {
		case startTime = "start_time", endTime = "end_time"
	}
}

struct CallBackSchedulesResponse: Decodable {
	let schedule: [CallBackTimeWindowResponse]?
}

struct CallBackSchedulingSettingsEntry: Decodable {
	let status: String?
	let dayOfWeek: [Int]?
	let startTime: [String]?
	let endTime: [String]?
	
	private enum CodingKeys: String, CodingKey {
		case status, dayOfWeek = "day_of_week", startTime = "start_time", endTime = "end_time"
	}
}

struct CallCenterSchedulingSettingsResponse: Decodable {
	let offerInterval: String?
	let maxScheduled: Int?
	let maxOptions: Int?
	let dailyOverflow: String?
	let profileSid: String?
	let entries: [CallBackSchedulingSettingsEntry]?
	
	private enum CodingKeys: String, CodingKey {
		case offerInterval = "offer_interval", maxScheduled = "max_scheduled", maxOptions = "max_options", dailyOverflow = "daily_overflow", profileSid = "profile_sid", entries
	}
}
