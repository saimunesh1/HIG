//
//  ClaimCellModel.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/13/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

// Implementing this as a class so that it can be handled by reference
class ClaimCellModel {
	
	var claimNumber: String?
	var accidentDescription: String?
	var accidentDateString: String?
	var claimStatus: ClaimStatus? // Determines icon and claim status text
	var claimDetails: String?
	var nextStepTitle: String?
	var nextStepDescription: String?
	var fnolClaim: FNOLClaim?
	var referenceNumber: Int? // Zero unless the claim has not yet been processed and has a reference number
	
}

extension ClaimCellModel {
	
	public func populateFrom(fnolClaim: FNOLClaim) {
		accidentDescription = fnolClaim.displayValue(forResponseKey: "accidentDetails.whatHappened.type")
		accidentDateString = fnolClaim.value(forResponseKey: "accidentDetails.dateOfAccident")
		claimStatus = ClaimStatus(rawValue: fnolClaim.status!)
		claimDetails = "" // TODO: Get this from somewhere
		nextStepDescription = "" // TODO: Figure this out based on claimStatus
		self.fnolClaim = fnolClaim
	}
	
	public func populateFrom(claimEntry: ClaimEntry) {
		claimStatus = claimEntry.status == "Open" ? ClaimStatus.claimEstablished : ClaimStatus.resolved
		claimNumber = claimEntry.claimNumber
		accidentDescription = "\(claimEntry.lossCause ?? "") in \(claimEntry.lossCity?.initialCapped ?? ""), \(claimEntry.lossState ?? "")"
		accidentDateString = claimEntry.dateOfLoss
		claimDetails = "" // TODO: Where does this come from?
		nextStepTitle = claimEntry.nextStepTitle
		nextStepDescription = claimEntry.nextStepDescription
		referenceNumber = claimEntry.referenceNumber
	}

}
