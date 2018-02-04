//
//  ClaimsOtherPeopleVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsOtherPeopleVC: ClaimsDetailsBaseVC {

	override func setUpFromClaim() {
		if let partiesInvolved = claim?.partyInvolvedList, partiesInvolved.count > 0 {
			for (index, partyInvolved) in partiesInvolved.enumerated() {
				
				// Heading
				infoCellModels.append(InfoCellModel(property: nil, value: "\(NSLocalizedString("claimreview.person", comment: "Person")) \(index + 1)", multiline: false, isHeading: true, tapResult: nil))
				
				// Name
				if let name = partyInvolved.name {
					infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.name", comment: "Name"), value: name, multiline: false, isHeading: false, tapResult: nil))
				}
				
				// Type
				if let type = partyInvolved.type {
					infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.type", comment: "Type"), value: type, multiline: false, isHeading: false, tapResult: nil))
				}
				
				//  Injured?
				if let injured = partyInvolved.injured {
					infoCellModels.append(InfoCellModel(property: NSLocalizedString("driverinfo.injured", comment: "Injured?"), value: injured, multiline: false, isHeading: false, tapResult: nil))
				}
				
				//  Transported from the scene?
				if let transported = partyInvolved.transportedFromScene {
					infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.transportedfromthescene", comment: "Transported from the scene?"), value: transported > 0 ? NSLocalizedString("alert.yes", comment: "Yes"): NSLocalizedString("alert.no", comment: "No"), multiline: false, isHeading: false, tapResult: nil))
				}
				
				//  Injury type
				if let injuryType = partyInvolved.injuryType {
					infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.injurydetails", comment: "Injury details"), value: injuryType, multiline: true, isHeading: false, tapResult: nil))
				}
				
				//  Injury detials
				if let injuryDetails = partyInvolved.injuryDetails {
					infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.injurydetails", comment: "Injury details"), value: injuryDetails, multiline: true, isHeading: false, tapResult: nil))
				}
			}
		}
	}

}
