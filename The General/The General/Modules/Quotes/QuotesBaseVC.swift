//
//  QuotesBaseVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import SafariServices

class QuotesBaseVC: BaseVC {
	
	public var zipCode: String?
}

extension QuotesBaseVC: SFSafariViewControllerDelegate {
	
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
		if !didLoadSuccessfully {
			controller.dismiss(animated: true, completion: {
				// TODO: Show alert
			})
		}
	}	
}
