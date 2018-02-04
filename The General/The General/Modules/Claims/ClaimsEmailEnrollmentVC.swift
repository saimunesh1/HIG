//
//  ClaimsEmailEnrollmentVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsEmailEnrollmentVC: BaseVC {

	@IBOutlet weak var yesNoSegmentController: YesNoSegmentControl!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		updatePreferencesSwitch()
    }

	@IBAction func didPressDone(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func didSwitch(_ sender: Any) {
		updateEmailPreferences()
	}
	
	private func updatePreferencesSwitch() {
		ApplicationContext.shared.preferencesManager.fetchPreferences(completion: { [weak self] (_) in
			guard let weakSelf = self else { return }
			let emailPreferences = ApplicationContext.shared.preferencesManager.preferenceInfo?.email
			if let claimUpdatesPreference = emailPreferences?.first(where: { $0.name == "claimUpdates" }) {
				weakSelf.yesNoSegmentController.selectedIndex = claimUpdatesPreference.enabled ? 0 : 1
			}
			LoadingView.hide()
		})
	}
	
	private func updateEmailPreferences() {
		let enrollInEmailUpdates = yesNoSegmentController.selectedIndex == 0 ? true : false
		if enrollInEmailUpdates {
			self.updateEmail(with: "global", newValue: true)
			self.updateEmail(with: "claimUpdates", newValue: true)
		} else {
			self.updateEmail(with: "claimUpdates", newValue: false)
		}
	}
	
	/// Update Email preferences and fetches latest
	///
	/// - Parameters:
	///   - preference: the email preference that needs to be updated
	///   - newValue: updated Bool value
	private func updateEmail(with preference: String, newValue: Bool) {
		let preferenceInfo: [String: Any] = [
			"preferenceName": "email",
			"preferences": [
				"name": preference,
				"enabled": newValue
			]
		]
		
		LoadingView.show()
		ApplicationContext.shared.preferencesManager.updatePreferences(with: preferenceInfo, completion: { [weak self] (_) in
			guard let weakSelf = self else { return }
			weakSelf.updatePreferencesSwitch()
		})
	}
	
}
