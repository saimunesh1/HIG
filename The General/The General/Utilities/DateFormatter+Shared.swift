//
//  DateFormatter+Shared.swift
//  The General
//
//  Created by Derek Bowen on 10/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

extension DateFormatter {

    static let shortMonthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return formatter
    }()

    static let monthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"

        return formatter
    }()

    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/yy"
        
        return formatter
    }()

    static let shortMonthDayYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        
        return formatter
    }()

    static let monthDayYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        
        return formatter
    }()
    
    static let twoDigitMonthDayFourDigitYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        return formatter
    }()
	
	static let hoursMilitary: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm"
		
		return formatter
	}()

	static let hoursCivilian: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "h:mm a"
		
		return formatter
	}()
    
	static let hoursCivilianWithTimeZone: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "h:mm a zzz"
		
		return formatter
	}()
	
	static let hoursCivilianWithSeconds: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "h:mm:ss a"
		
		return formatter
	}()
	
    static let hourMinuteMeridiemTimezone: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a v"
        
        return formatter
    }()
	
	static let callbackDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		return formatter
	}()
	
    static let callbackTimezoneDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ssz"
        
        return formatter
    }()
    
    static let fullDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a"
        
        return formatter
    }()
	
	static let holidayDate: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

		return formatter
	}()
	
	static let insuranceEffectiveDate: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MM/dd/yyyy HH:mm"
		
		return formatter
	}()
    
    static let monthDayYearStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        return formatter
    }()

    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return formatter
    }()

}
