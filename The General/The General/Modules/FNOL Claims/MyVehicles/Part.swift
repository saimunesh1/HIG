//
//  Part.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/17/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

public enum Part: String {
	
	case driverFrontWheel
	case frontBumper
	case passengerFrontWheel
	case driverFender
	case hood
	case passengerFender
	case driverFrontDoor
	case windshield
	case passengerFrontDoor
	case driverRearDoor
	case roof
	case passengerRearDoor
	case driverQuarterPanel
	case trunk
	case passengerQuarterPanel
	case driverRearWheel
	case rearBumper
	case passengerRearWheel
	
	init?(index: Int) {
		switch index {
		case 0: self = .driverFrontWheel
		case 1: self = .driverFender
		case 2: self = .driverFrontDoor
		case 3: self = .driverRearDoor
		case 4: self = .driverQuarterPanel
		case 5: self = .driverRearWheel
		case 6: self = .frontBumper
		case 7: self = .hood
		case 8: self = .windshield
		case 9: self = .roof
		case 10: self = .trunk
		case 11: self = .rearBumper
		case 12: self = .passengerFrontWheel
		case 13: self = .passengerFender
		case 14: self = .passengerFrontDoor
		case 15: self = .passengerRearDoor
		case 16: self = .passengerQuarterPanel
		case 17: self = .passengerRearWheel
		default:
			return nil
		}
	}
	
	var index: Int {
		switch self {
		case .driverFrontWheel: return 0
		case .driverFender: return 1
		case .driverFrontDoor: return 2
		case .driverRearDoor: return 3
		case .driverQuarterPanel: return 4
		case .driverRearWheel: return 5
		case .frontBumper: return 6
		case .hood: return 7
		case .windshield: return 8
		case .roof: return 9
		case .trunk: return 10
		case .rearBumper: return 11
		case .passengerFrontWheel: return 12
		case .passengerFender: return 13
		case .passengerFrontDoor: return 14
		case .passengerRearDoor: return 15
		case .passengerQuarterPanel: return 16
		case .passengerRearWheel: return 17
		}
	}
	
}
