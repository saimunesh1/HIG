//
//  LocationHandler.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/29/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import CoreLocation

open class LocationHandler {
    
    static func isLocationPermissionGranted() -> Bool {
        guard CLLocationManager.locationServicesEnabled() else { return false }
        return [.notDetermined , .authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())
    }
}
