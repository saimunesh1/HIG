//
//  FNOLBaseVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/27/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class FNOLBaseVC: BaseVC {

	internal func showSaveQuitActionSheet() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alertController.addAction(UIAlertAction(title: NSLocalizedString("alert.saveandquit", comment: "Save and quit"), style: .default, handler: { (action) in
			PersistenceManager.shared.saveToPersistentStore()
			self.navigationController?.popToRootViewController(animated: true)
		}))
		alertController.addAction(UIAlertAction(title: NSLocalizedString("alert.quitwithoutsaving", comment: "Quit without saving"), style: .destructive, handler: { (action) in
			ApplicationContext.shared.fnolClaimsManager.deleteActiveClaim()
			self.navigationController?.popToRootViewController(animated: true)
		}))
		alertController.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", comment: "Cancel"), style: .cancel, handler: { (action) in
		}))
		present(alertController, animated: true, completion: nil)
	}

	func showConfirmAlert(message: String) {
		let alertController = UIAlertController(title: NSLocalizedString("alert.title", comment: ""), message: message, preferredStyle: .alert)
		
		let yesAction = UIAlertAction(title: NSLocalizedString("alert.yes", comment: ""), style: .default) { (action) in
			alertController.removeFromParentViewController()
			self.navigationController?.popViewController(animated: true)
		}
		alertController.addAction(yesAction)
		let noAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("alert.no", comment: ""), style: .cancel, handler: { (UIAlertAction)in
			alertController.removeFromParentViewController()
		})
		alertController.addAction(noAction)
		self.present(alertController, animated: true, completion: nil)
	}

}
