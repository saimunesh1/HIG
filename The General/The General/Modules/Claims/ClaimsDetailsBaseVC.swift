//
// ClaimsDetailsBaseVC.swift
// The General
//
// Created by Alyn, Trevor (US - Denver) on 12/18/17.
// Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsDetailsBaseVC: BaseVC {

	struct InfoCellModel {
		var property: String?
		var value: String
		var multiline: Bool
		var isHeading: Bool
		var tapResult: (() -> Void)?
	}
	
	@IBOutlet weak var tableView: UITableView!
	
	public var claim: Claim? { didSet { setUpFromClaim() }}

	internal var infoCellModels = [InfoCellModel]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.tableFooterView = UIView() // Hides separators between empty rows
		registerNibs()
	}
	
	private func registerNibs() {
		tableView.register(ClaimsDamagedPartsCell.nib, forCellReuseIdentifier: ClaimsDamagedPartsCell.identifier)
		tableView.register(ClaimsHeadingCell.nib, forCellReuseIdentifier: ClaimsHeadingCell.identifier)
		tableView.register(ClaimsInfoCell.nib, forCellReuseIdentifier: ClaimsInfoCell.identifier)
		tableView.register(ClaimsMultilineInfoCell.nib, forCellReuseIdentifier: ClaimsMultilineInfoCell.identifier)
	}
	
	internal func setUpFromClaim() {
		infoCellModels = [InfoCellModel]()
	}
	
	internal func addressStringFromFields(address1: String?, address2: String?, address3: String?, city: String?, state: String?, zip: String?) -> String {
		var addressString = ""
		if let address1 = address1, !address1.isEmpty { addressString += "\(address1.trimmingCharacters(in: .whitespacesAndNewlines).initialCapped)\n" }
		if let address2 = address2, !address2.isEmpty { addressString += "\(address2.trimmingCharacters(in: .whitespacesAndNewlines).initialCapped)\n" }
		if let address3 = address3, !address3.isEmpty { addressString += "\(address3.trimmingCharacters(in: .whitespacesAndNewlines).initialCapped)" }
		addressString = "\(addressString.trimmingCharacters(in: .whitespacesAndNewlines))\n"
		if let city = city { addressString += city.initialCapped }
		if let state = state { addressString += ", \(state)" }
		if let zip = zip { addressString += " \(zip)" }
		return addressString.trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	internal func vehicleDescriptionStringFrom(vehicle: Vehicle) -> String {
		var vehicleDescriptionString = ""
		if let make = vehicle.make {
			vehicleDescriptionString += make.initialCapped
		}
		if let model = vehicle.model {
			vehicleDescriptionString += " \(model.initialCapped)"
		}
		if let year = vehicle.year {
			vehicleDescriptionString += " \(year)"
		}
		vehicleDescriptionString = vehicleDescriptionString + "\n"
		if let licensePlate = vehicle.licensePlate, !licensePlate.isEmpty {
			vehicleDescriptionString += "\(NSLocalizedString("claims.licenseplate", comment: "License plate")) \(licensePlate)\n"
		}
		if let color = vehicle.color, !color.isEmpty {
			vehicleDescriptionString += color
		}
		return vehicleDescriptionString.trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	internal func addRowsForVehiclePerson(vehiclePerson: VehiclePerson) {
		
		// Name
		if let name = vehiclePerson.name {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.name", comment: "Name"), value: name.initialCapped, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Address
		// TODO: Fix this
		let address = addressStringFromFields(address1: vehiclePerson.address1, address2: vehiclePerson.address2, address3: vehiclePerson.address3, city: vehiclePerson.city, state: vehiclePerson.state, zip: vehiclePerson.postalCode)
		if address.trimmingCharacters(in: .whitespacesAndNewlines).count > 1 {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.address", comment: "Address"), value: address, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Phone number
		if let phoneNumber = vehiclePerson.phoneNumber {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.phonenumber", comment: "Phone number"), value: phoneNumber, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Injured?
		if let injured = vehiclePerson.injured {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("driverinfo.injured", comment: "Injured?"), value: injured, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Transported from the scene?
		if let transported = vehiclePerson.transportedFromScene {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.transportedfromthescene", comment: "Transported from the scene?"), value: transported, multiline: false, isHeading: false, tapResult: nil))
		}
		
		// Injury type
		if let injuryType = vehiclePerson.injuryType {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.injurydetails", comment: "Injury details"), value: injuryType, multiline: true, isHeading: false, tapResult: nil))
		}
	}
	
	internal func addRowsForDriverAndPassengers(vehicle: Vehicle) {

		// Driver, if any
		if let driver = vehicle.vehiclePersonList?.filter({ $0.type == "Driver" }).first {
			
			// Driver heading
			infoCellModels.append(InfoCellModel(property: nil, value: NSLocalizedString("driverinfo.driver", comment: "Driver"), multiline: false, isHeading: true, tapResult: nil))
			
			addRowsForVehiclePerson(vehiclePerson: driver)
		}
		
		// Passengers, if any
		if let passengers = vehicle.vehiclePersonList?.filter({ $0.type != "Driver" }), passengers.count > 0 {
			for passenger in passengers {
				
				// Passenger heading
				infoCellModels.append(InfoCellModel(property: nil, value: NSLocalizedString("claimreview.passenger", comment: "Passenger"), multiline: false, isHeading: true, tapResult: nil))
				
				addRowsForVehiclePerson(vehiclePerson: passenger)
			}
		}
	}
	
}

extension ClaimsDetailsBaseVC: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return infoCellModels.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let infoCellModel = infoCellModels[indexPath.row]
		if infoCellModel.property == "Damaged parts" {
			let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsDamagedPartsCell.identifier, for: indexPath) as! ClaimsDamagedPartsCell
			cell.partsListLabel.text = infoCellModel.value
			return cell
		}
		if infoCellModel.isHeading {
			let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsHeadingCell.identifier, for: indexPath) as! ClaimsHeadingCell
			cell.headingLabel.text = infoCellModel.value
			return cell
		}
		var cell: ClaimsInfoCell!
		switch infoCellModel.multiline {
		case true:
			cell = tableView.dequeueReusableCell(withIdentifier: ClaimsMultilineInfoCell.identifier, for: indexPath) as! ClaimsMultilineInfoCell
		case false:
			cell = tableView.dequeueReusableCell(withIdentifier: ClaimsInfoCell.identifier, for: indexPath) as! ClaimsInfoCell
		}
		if infoCellModel.tapResult != nil {
			cell.isInteractive = true
		}
		cell.propertyLabel.text = infoCellModel.property
		cell.valueLabel.text = infoCellModel.value
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let tapResult = infoCellModels[indexPath.row].tapResult {
			tapResult()
		}
	}
	
}
