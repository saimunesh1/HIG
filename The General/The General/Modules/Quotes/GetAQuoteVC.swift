//
//  GetAQuoteVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import SafariServices

class GetAQuoteVC: QuotesBaseVC, QuoteNavigatable {
	
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		registerNibs()
	}
	
	private func registerNibs() {
		tableView.register(QuoteContinueButtonCell.nib, forCellReuseIdentifier: QuoteContinueButtonCell.identifier)
		tableView.register(QuoteGetQuoteByPhoneCell.nib, forCellReuseIdentifier: QuoteGetQuoteByPhoneCell.identifier)
		tableView.register(QuoteZipCodeEntryCell.nib, forCellReuseIdentifier: QuoteZipCodeEntryCell.identifier)
	}

	override func goBack(segue: UIStoryboardSegue) {
		if SessionManager.accessToken == nil {
			ApplicationContext.shared.navigator.replace("pgac://login", context: nil, wrap: nil, handleDrawerController: false)
		} else {
			super.goBack(segue: segue)
		}
	}

}

extension GetAQuoteVC: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.row {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: QuoteZipCodeEntryCell.identifier, for: indexPath) as! QuoteZipCodeEntryCell
			cell.delegate = self
			cell.zipCodeTextField.text = zipCode
			return cell
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: QuoteGetQuoteByPhoneCell.identifier, for: indexPath) as! QuoteGetQuoteByPhoneCell
			cell.leftAlign = true
			cell.delegate = self
			return cell
		case 2:
			let cell = tableView.dequeueReusableCell(withIdentifier: QuoteContinueButtonCell.identifier, for: indexPath) as! QuoteContinueButtonCell
			cell.delegate = self
			return cell
		default:
			return UITableViewCell()
		}
	}
	
}

extension GetAQuoteVC: QuoteZipCodeEntryCellDelegate {
	
	func didPressLocate() {
		ApplicationContext.shared.locationManager.checkLocationAccess(success: {
			ApplicationContext.shared.locationManager.getAddressFromLocation(completion: { (address) in
				self.zipCode = address?.zip
				self.tableView.reloadData()
			})
		}, failure: {
			self.showLocationDisabledAlert()
		})
	}
	
	func didUpdate(zipCode: String?) {
		self.zipCode = zipCode
	}
	
}

extension GetAQuoteVC: QuoteGetQuoteByPhoneCellDelegate {
	
	func didPressGetQuoteByPhone() {
		showGetAQuoteByPhoneActionSheet()
	}
	
}

extension GetAQuoteVC: QuoteContinueButtonCellDelegate {
	
	func didPressContinue() {
		if let _ = SessionManager.accessToken {
            showGetAQuoteActionSheet(zipCode: zipCode)
		} else {
            getBrandNewQuote(zipCode: zipCode)
		}
	}
	
}
