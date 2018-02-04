//
//  NetworkReachability.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/9/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import SystemConfiguration

enum ReachabilityStatus {
	case notReachable
	case reachableViaWiFi
	case reachableViaWWAN
}

public class NetworkReachability {
	
	class func isConnectedToNetwork() -> Bool {
		
		var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
		zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
		zeroAddress.sin_family = sa_family_t(AF_INET)
		
		let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
				SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
			}
		}
		
		var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
		if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
			return false
		}

		// Working for Cellular and WIFI
		let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
		let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
		let ret = (isReachable && !needsConnection)
		
		return ret
		
	}
	
	class func networkConnectionType() -> ReachabilityStatus {
		var zeroAddress = sockaddr_in()
		zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
		zeroAddress.sin_family = sa_family_t(AF_INET)
		guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
				SCNetworkReachabilityCreateWithAddress(nil, $0)
			}
		}) else {
			return .notReachable
		}
		var flags: SCNetworkReachabilityFlags = []
		if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
			return .notReachable
		}
		if flags.contains(.reachable) == false {
			// The target host is not reachable.
			return .notReachable
		}
		else if flags.contains(.isWWAN) == true {
			// WWAN connections are OK if the calling application is using the CFNetwork APIs.
			return .reachableViaWWAN
		}
		else if flags.contains(.connectionRequired) == false {
			// If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
			return .reachableViaWiFi
		}
		else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
			// The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
			return .reachableViaWiFi
		}
		else {
			return .notReachable
		}
	}
	
}
