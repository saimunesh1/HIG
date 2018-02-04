//
// ClaimsOtherVehicleDetailsVC.swift
// The General
//
// Created by Alyn, Trevor (US - Denver) on 12/18/17.
// Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsOtherVehicleDetailsVC: ClaimsDetailsBaseVC {

	public var vehicleIndex: Int! // Must be set *before* you set the vehicle
	public var vehicle: Vehicle! { didSet { setUpFromVehicle() } }
	
	func setUpFromVehicle() {
		guard let vehicleIndex = vehicleIndex else { return }
		navigationItem.title = "\(NSLocalizedString("claimreview.vehicle", comment: "Vehicle")) \(vehicleIndex + 2)"
		
		infoCellModels = [InfoCellModel]()
		
		// Vehicle description
		let vehicleDescriptionString = vehicleDescriptionStringFrom(vehicle: vehicle)
		if !vehicleDescriptionString.isEmpty {
			infoCellModels.append(InfoCellModel(property: "\(NSLocalizedString("claimreview.vehicle", comment: "Vehicle")) \(vehicleIndex + 2)", value: vehicleDescriptionString, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Owner
		if let vehicleOwner = vehicle.vehicleOwner {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.vehicleowner", comment: "Vehicle's owner"), value: vehicleOwner, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Severity of damage
		if let severityOfDamage = vehicle.severityOfDamage {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.severityofdamage", comment: "Severity of damage"), value: "\(severityOfDamage)", multiline: false, isHeading: false, tapResult: nil))
		}
		
		addRowsForDriverAndPassengers(vehicle: vehicle)

		// TODO: Supporting documents?
	}

}
