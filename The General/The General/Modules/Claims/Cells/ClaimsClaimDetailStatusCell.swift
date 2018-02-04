//
//  ClaimsClaimDetailStatusCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/14/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol ClaimsClaimDetailStatusCellDelegate: class {
	func didTapActionLink(cell: ClaimsClaimDetailStatusCell)
	func didTapInfoButton()
}

class ClaimsClaimDetailStatusCell: BaseTableViewCell {

	@IBOutlet weak var progressView: ClaimsProgressView!
	@IBOutlet weak var infoButton: UIButton!
	@IBOutlet weak var claimStatusLabel: UILabel!
	@IBOutlet weak var claimDetailLabel: UILabel!
	@IBOutlet weak var nextStepLabel: UILabel!
	@IBOutlet weak var nextStepDetailsLabel: UILabel!
	@IBOutlet weak var actionLinkLabel: UILabel!
	@IBOutlet weak var actionLinkButton: UIButton!
	@IBOutlet var labels: [UILabel]!
	
	public weak var delegate: ClaimsClaimDetailStatusCellDelegate?
	public var claim: Claim? { didSet { setUpFromClaim() } }
	
	override func awakeFromNib() {
        super.awakeFromNib()
		infoButton.tintColor = .tgGreen
		actionLinkLabel.textColor = .tgGreen
		actionLinkButton.isEnabled = false
		clearLabels()
    }
	
	private func clearLabels() {
		for label in labels { label.text = "" }
		progressView.isHidden = false
	}

	private func setUpFromClaim() {
		clearLabels()
		if let claimStatus = claim?.claimStatus {
			switch claimStatus {
			case .draftSaved:
				claimStatusLabel.text = NSLocalizedString("claims.draftsaved", comment: "Draft saved")
				actionLinkLabel.text = NSLocalizedString("claims.continueclaim", comment: "Continue claim")
				actionLinkButton.isEnabled = true
				nextStepLabel.text = NSLocalizedString("claims.nextstep", comment: "Next step")
				nextStepDetailsLabel.text = NSLocalizedString("claims.yourclaimisntcomplete", comment: "Your claim isn't complete.")
				progressView.isHidden = true
			case .claimSaved:
				claimStatusLabel.text = NSLocalizedString("claims.claimsaved", comment: "Claim saved")
				claimDetailLabel.text = NSLocalizedString("claims.yourclaimwassaved", comment: "Your claim was saved.")
				nextStepLabel.text = NSLocalizedString("claims.nextstep", comment: "Next step")
				nextStepDetailsLabel.text = NSLocalizedString("claims.sendlater", comment: "You can send your claim later over a wi-fi connection.")
				actionLinkLabel.text = NSLocalizedString("claims.sendnow", comment: "Send now")
				actionLinkButton.isEnabled = true
				progressView.isHidden = true
			case .uploadingClaim:
				claimStatusLabel.text = NSLocalizedString("claims.uploadingclaim", comment: "Uploading claim")
				progressView.isHidden = true
			case .claimSubmitted:
				claimStatusLabel.text = NSLocalizedString("claims.claimsent", comment: "Claim sent")
				claimDetailLabel.text = NSLocalizedString("claims.received", comment: "We received your claim.")
				actionLinkLabel.text = NSLocalizedString("claims.enrollinemailupdates", comment: "Enroll in email updates")
				actionLinkButton.isEnabled = true
			case .claimEstablished:
				claimStatusLabel.text = NSLocalizedString("claims.claimestablished", comment: "Claim established")
				claimDetailLabel.text = NSLocalizedString("claims.assignedtoadjuster", comment: "Your claim has been established and has been assigned to an adjuster.")
				actionLinkLabel.text = NSLocalizedString("claims.contactadjuster", comment: "Contact adjuster")
				actionLinkButton.isEnabled = true
			case .appraisalRequested:
				claimStatusLabel.text = NSLocalizedString("claims.appraisalrequested", comment: "Appraisal requested")
				claimDetailLabel.text = NSLocalizedString("claims.appraisalrequesteddetail", comment: "An appraisal has been requested on your vehicle.")
			case .resolved:
				claimStatusLabel.text = ""
			}
		}
		guard let claim = claim else { return }
		if let numberOfSteps = claim.totalSteps {
			progressView.numberOfSteps = numberOfSteps
		}
		if let nextStepNumber = claim.nextStepNumber {
			progressView.setCurrentStep(index: nextStepNumber - 1)
		}
		if let nextStep = claim.nextStep, let nextStepDetails = claim.nextStepDescription {
			nextStepLabel.text = nextStep
			nextStepDetailsLabel.text = nextStepDetails
		}
	}
	
	@IBAction func didTapInfoButton(_ sender: Any) {
		delegate?.didTapInfoButton()
	}
	
	@IBAction func didTapActionLink(_ sender: Any) {
		delegate?.didTapActionLink(cell: self)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		clearLabels()
	}
}
