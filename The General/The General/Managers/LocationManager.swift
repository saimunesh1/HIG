//
//  LocationManager.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {

	private var clLocationManager: CLLocationManager!
	private var deviceLocation: CLLocation?
	private var success: (() -> Void)?
	private var failure: (() -> Void)?
	
	override init() {
		super.init()
		clLocationManager = CLLocationManager()
		clLocationManager.delegate = self
		clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
	}

	public func checkLocationAccess(success: @escaping () -> Void, failure: @escaping () -> Void) {
		self.success = success
		self.failure = failure
		switch CLLocationManager.authorizationStatus() {
		case .notDetermined:
			clLocationManager.requestWhenInUseAuthorization()
		case .authorizedAlways, .authorizedWhenInUse:
			clLocationManager.startUpdatingLocation()
		case .denied, .restricted:
			failure()
		}
	}
	
	public func getAddressFromLocation(completion: @escaping (FNOLAddressTemporary?) -> Void) {
		let geoCoder = CLGeocoder()
		if let deviceLocation = deviceLocation {
			geoCoder.reverseGeocodeLocation(deviceLocation, completionHandler: { (placemarks, error) -> Void in
				if error != nil {
					self.failure?()
					self.failure = nil
					return
				}
				var placeMark: CLPlacemark?
				placeMark = placemarks?[0]
				guard let country = placeMark?.country,
					let subThoroughfare = placeMark?.subThoroughfare,
					let thoroughfare = placeMark?.thoroughfare,
					let zip = placeMark?.postalCode,
					let city = placeMark?.locality,
					let state = placeMark?.administrativeArea else { return }
				var address = FNOLAddressTemporary()
				address.country = country
				address.zip = zip
				address.city = city
				address.street = subThoroughfare + " " + thoroughfare
				address.state = state
				completion(address)
			})
		} else {
			completion(nil)
		}
	}
	
}

extension LocationManager: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .authorizedWhenInUse, .authorizedAlways:
			manager.startUpdatingLocation()
		case .restricted, .denied:()
			// Don't call the failure block because it will immediately show the alert that
			// points the user to the Settings
			break
		default:
			break
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let locationArray = locations as NSArray
		guard let location = (locationArray.lastObject as? CLLocation) else {
			failure?()
			return
		}
		deviceLocation = location
		success?()
		success = nil
		clLocationManager.stopUpdatingLocation()
	}
	
}
