//
//  Date+Custom.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

extension Date {
	
	// Returns a number from 1 (Sunday) to 7 (Saturday)
	func dayNumberOfWeek() -> Int? {
		return Calendar.current.dateComponents([.weekday], from: self).weekday
	}

	func weekdayNameForCallBackTimeWindows() -> String? {
		guard let dayNumberOfWeek = self.dayNumberOfWeek() else { return nil }
		switch dayNumberOfWeek {
		case 1:
			return "sunday"
		case 2:
			return "monday"
		case 3:
			return "tuesday"
		case 4:
			return "wednesday"
		case 5:
			return "thursday"
		case 6:
			return "friday"
		case 7:
			return "saturday"
		default:
			return nil
		}
	}
	
	func withTodaysYearMonthDay() -> Date? {
		var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: self)
		let todayTimeComponents = Calendar.current.dateComponents([.month, .year, .day], from: Date())
		dateComponents.year = todayTimeComponents.year
		dateComponents.month = todayTimeComponents.month
		dateComponents.day = todayTimeComponents.day
		if let newDate = Calendar.current.date(from: dateComponents) {
			return newDate
		}
		return nil
	}

    func daysBetween() -> Int? {
        return Date.daysBetween(start: Date(), end: self)
    }
    
    static func daysBetween(start: Date, end: Date) -> Int? {
        let calendar = Calendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: start)
        let date2 = calendar.startOfDay(for: end)
        
        let a = calendar.dateComponents([.day], from: date1, to: date2)
        return a.value(for: .day)
    }
    
    func dateNowString() -> String {
        let dateFormatter = DateFormatter.monthDayYearStyle
        return dateFormatter.string(from: self)
    }
}
