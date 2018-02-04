//
//  DamageDetailsProtocols.swift
//  The General
//
//  Created by Michael Moore on 10/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

//Delegate for Dmaged details
protocol DamageDetailsFooterDelegate {
    func touchOnDone()
}

//delegate for Segment value
protocol SegmentControlDelegate {
    func segmentValueChanged(field: Field, value: String)
}

//Delegate for vehicle Section
protocol VehicleListFooterDelegate {
    func didTouchonOtherVehicle()
    func didTouchonSaveExit(isSave: Bool)
    func didTouchonAddVehicle(vehicle: FNOLVehicle)
    
}
