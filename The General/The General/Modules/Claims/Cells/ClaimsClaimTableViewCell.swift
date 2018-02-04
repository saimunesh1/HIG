//
//  ClaimsClaimTableViewCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/13/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsClaimTableViewCell: BaseTableViewCell {
	
	@IBOutlet weak var shadowedView: UIView!
	@IBOutlet weak var claimNumberLabel: UILabel!
	@IBOutlet weak var accidentDescriptionLabel: UILabel!
	@IBOutlet weak var accidentDateLabel: UILabel!
	@IBOutlet weak var topSeparatorView: UIView!
	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var claimStatusLabel: UILabel!
	@IBOutlet weak var claimDetailLabel: UILabel!
	@IBOutlet weak var nextStepLabel: UILabel!
	@IBOutlet weak var nextStepDetailsLabel: UILabel!
	@IBOutlet weak var actionLinkLabel: UILabel!
	@IBOutlet weak var claimNumberLabelTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var accidentDescriptionTopConstraint: NSLayoutConstraint!
	@IBOutlet var labels: [UILabel]!
	@IBOutlet var collapsableConstraints: [NSLayoutConstraint]!
	
	private var collapsibleConstraintValues = [CGFloat]()
	
	public var claimCellModel: ClaimCellModel? {
		didSet {
			saveCollapsibleConstraintValues()
			guard let claimCellModel = claimCellModel else { return }
			clearLabels()
			if let claimNumber = claimCellModel.claimNumber, !claimNumber.isEmpty {
				claimNumberLabel.text = "\(NSLocalizedString("claims.claimnumber", comment: "Claim")) \(claimNumber)"
				accidentDescriptionTopConstraint.constant = 0.0
			} else {
				accidentDescriptionTopConstraint.constant = 5.0
			}
			if claimNumberLabel.text == nil || claimNumberLabel.text!.isEmpty {
				claimNumberLabelTopConstraint.constant = 0.0
			}
			accidentDescriptionLabel.text = claimCellModel.accidentDescription
			accidentDateLabel.text = claimCellModel.accidentDateString
			if let nextStepDetails = claimCellModel.nextStepDetails, !nextStepDetails.isEmpty {
				nextStepLabel.text = NSLocalizedString("claims.nextstep", comment: "Next step")
				nextStepDetailsLabel.text = nextStepDetails
			}
			if let cellType = claimCellModel.cellType {
				switch cellType {
				case .draftSaved:
					iconImageView.image = UIImage(named: "24px__claim-draft-saved")
					claimStatusLabel.text = NSLocalizedString("claims.draftsaved", comment: "Draft saved")
				case .uploadingClaim:
					iconImageView.image = UIImage(named: "24px_claim_uploading")
					claimStatusLabel.text = NSLocalizedString("claims.uploadingclaim", comment: "Uploading claim")
				case .claimSaved:
					iconImageView.image = UIImage(named: "24px__claim-saved")
					claimStatusLabel.text = NSLocalizedString("claims.claimsaved", comment: "Claim saved")
					actionLinkLabel.text = NSLocalizedString("claims.sendnow", comment: "Send now")
				case .claimSavedNoWiFiConnection:
					iconImageView.image = UIImage(named: "24px__no-wifi")
					iconImageView.tintColor = .red
					claimStatusLabel.text = NSLocalizedString("claims.claimsavednowifi", comment: "Claim saved, no wi-fi connection")
					actionLinkLabel.text = NSLocalizedString("claims.sendnow", comment: "Send now")
				case .claimSent:
					iconImageView.image = UIImage(named: "24px__claim-sent")
					claimStatusLabel.text = NSLocalizedString("claims.claimsent", comment: "Claim sent")
					actionLinkLabel.text = NSLocalizedString("claims.enrollinemailupdates", comment: "Enroll in email updates")
				case .claimEstablished:
					iconImageView.image = UIImage(named: "24px__claim-established")
					claimStatusLabel.text = NSLocalizedString("claims.claimestablished", comment: "Claim established")
					actionLinkLabel.text = NSLocalizedString("claims.contactadjuster", comment: "Contact adjuster")
				case .appraisalRequested:
					iconImageView.image = UIImage(named: "24px__clipboard")
					claimStatusLabel.text = NSLocalizedString("claims.appraisalrequested", comment: "Appraisal requested")
					actionLinkLabel.text = NSLocalizedString("claims.contactadjuster", comment: "Contact adjuster")
				case .resolved:
					iconImageView.image = nil
					claimStatusLabel.text = ""
					collapseConstraints()
				}
			}
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
		topSeparatorView.backgroundColor = .tgGray
		shadowedView.layer.shadowColor = UIColor.black.cgColor
		shadowedView.layer.shadowOffset = CGSize(width: -5.0, height: 5.0)
		shadowedView.layer.shadowRadius = 5.0
		shadowedView.layer.shadowOpacity = 0.35
    }
	
	private func clearLabels() {
		for label in labels { label.text = "" }
	}
	
	private func saveCollapsibleConstraintValues() {
		collapsibleConstraintValues = [CGFloat]()
		for constraint in collapsableConstraints {
			collapsibleConstraintValues.append(constraint.constant)
		}
	}
	
	private func restoreCollapsibleConstraintValues() {
		for (index, constraint) in collapsableConstraints.enumerated() {
			constraint.constant = collapsibleConstraintValues[index]
		}
	}
	
	private func collapseConstraints() {
		for constraint in collapsableConstraints {
			constraint.constant = 0.0
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		clearLabels()
		claimNumberLabelTopConstraint.constant = 8.0
		restoreCollapsibleConstraintValues()
		iconImageView.tintColor = .black
		iconImageView.image = nil
	}

}
