//
//  ClaimsAccidentDetailsVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/16/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsAccidentDetailsVC: ClaimsDetailsBaseVC {

	override func setUpFromClaim() {
		infoCellModels = [InfoCellModel]()
		if let accidentType = claim?.lossType {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.accidenttype", comment: "Accident type"), value: accidentType, multiline: false, isHeading: false, tapResult: nil))
		}
		if let location = claim?.lossLocation {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.location", comment: "Location"), value: location, multiline: false, isHeading: false, tapResult: nil))
		}
		let addressString = addressStringFromFields(address1: claim!.address1, address2: claim!.address2, address3: claim!.address3, city: claim!.city, state: claim!.state, zip: claim!.postalCode)
		if !addressString.isEmpty && addressString.trimmingCharacters(in: .whitespacesAndNewlines).count > 1 {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.address", comment: "Address"), value: addressString, multiline: false, isHeading: false, tapResult: nil))
		}
		var whenString = ""
		if let lossDate = claim?.lossDate { whenString += "\(lossDate)\n" }
		if let lossTime = claim?.lossTime { whenString += "\(NSLocalizedString("claims.around", comment: "Around")) \(lossTime)" }
		if !whenString.isEmpty {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.when", comment: "When"), value: whenString, multiline: false, isHeading: false, tapResult: nil))
		}
		if let lossDetails = claim?.lossDetails {
			infoCellModels.append(InfoCellModel(property: NSLocalizedString("claimreview.details", comment: "Details"), value: lossDetails, multiline: true, isHeading: false, tapResult: nil))
		}
	}
}
