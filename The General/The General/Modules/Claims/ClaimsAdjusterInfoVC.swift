//
//  ClaimsAdjusterInfoVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/19/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import MessageUI

class ClaimsAdjusterInfoVC: ClaimsDetailsBaseVC {

	public var adjusterInfo: ClaimAdjusterResponse? { didSet { setUpFromAdjusterInfo() }}

	private func setUpFromAdjusterInfo() {
		infoCellModels = [InfoCellModel]()
		
		if let adjusterInfo = adjusterInfo, let adjusters = adjusterInfo.adjusters {
			for adjuster in adjusters {
				
				// Adjuster heading
				infoCellModels.append(InfoCellModel(property: nil, value: adjuster.coverageType!, multiline: false, isHeading: true, tapResult: nil))

				// Name
				if let name = adjuster.name {
					infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.name", comment: "Name"), value: name, multiline: false, isHeading: false, tapResult: nil))
				}

				// Phone number
				if let phoneNumber = adjuster.phoneNumber, phoneNumber.count > 0 {
					infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.phonenumber", comment: "Phone number"), value: phoneNumber, multiline: false, isHeading: false, tapResult: {
						let cleanPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
						if let url = URL(string: "tel://\(cleanPhoneNumber)"), UIApplication.shared.canOpenURL(url) {
							UIApplication.shared.open(url, options: [:], completionHandler: nil)
						}
					}))
				}

				// Extension
				if let phoneExtension = adjuster.`extension` {
					infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.extension", comment: "Extension"), value: phoneExtension, multiline: false, isHeading: false, tapResult: nil))
				}
				
				// Email
				if let emailAddress = adjuster.emailAddress, emailAddress.count > 0 {
					infoCellModels.append(InfoCellModel(property: NSLocalizedString("claims.emailaddress", comment: "Email address"), value: emailAddress, multiline: false, isHeading: false, tapResult: { [weak self] in
						guard let weakSelf = self else { return }
						guard MFMailComposeViewController.canSendMail() else { return }
						let composeVC = MFMailComposeViewController()
						composeVC.mailComposeDelegate = weakSelf
						composeVC.setToRecipients([emailAddress])
						composeVC.setSubject("")
						composeVC.setMessageBody("", isHTML: false)
						// Using this method because otherwise, the views collapse when email controller is dismissed (https://forums.developer.apple.com/thread/62012)
						guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
						rootViewController.present(composeVC, animated: true, completion: nil)
					}))
				}
			}
		}
	}
	
}

extension ClaimsAdjusterInfoVC: MFMailComposeViewControllerDelegate {
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
	
}
