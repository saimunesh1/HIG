//
//  QuotesVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import SafariServices

class QuotesVC: QuotesBaseVC {
	
	@IBOutlet weak var tableView: UITableView!
	
	private var existingQuotes = [QuoteResponse]()
	private var isSsoAvailable = false

    override func viewDidLoad() {
        super.viewDidLoad()
		registerNibs()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Only show the hamburger if the user is logged in
		if SessionManager.accessToken != nil {
			baseNavigationController?.showMenuButton()
		}
		
		// Only try to show quotes if SSO is turned on
		if let sso = ApplicationContext.shared.configurationManager.configuration?.quote?.useSso {
			isSsoAvailable = sso
			getExistingQuotes()
		}
	}

	private func registerNibs() {
		tableView.register(QuoteTextCell.nib, forCellReuseIdentifier: QuoteTextCell.identifier)
		tableView.register(QuoteGetQuoteButtonCell.nib, forCellReuseIdentifier: QuoteGetQuoteButtonCell.identifier)
		tableView.register(QuoteGetQuoteByPhoneCell.nib, forCellReuseIdentifier: QuoteGetQuoteByPhoneCell.identifier)
		tableView.register(QuoteNoQuotesCell.nib, forCellReuseIdentifier: QuoteNoQuotesCell.identifier)
		tableView.register(QuoteExistingQuoteCell.nib, forCellReuseIdentifier: QuoteExistingQuoteCell.identifier)
		tableView.register(QuoteSeePreviousQuotesCell.nib, forCellReuseIdentifier: QuoteSeePreviousQuotesCell.identifier)
		tableView.register(QuotePreviousQuotesHeaderView.nib, forHeaderFooterViewReuseIdentifier: QuotePreviousQuotesHeaderView.identifier)
	}
	
	private func getExistingQuotes() {
		
		// Only get existing quotes if the user is logged in
		if SessionManager.accessToken != nil {
			guard ApplicationContext.shared.configurationManager.configuration?.quote?.useSso == true else { return }
			ApplicationContext.shared.quotesManager.getExistingQuotes(completion: { (innerClosure) in
				do {
					let quotes = try innerClosure()
                    self.existingQuotes = quotes
                    self.tableView.reloadData()
				}
				catch let error {
					print("Error retrieving quotes: \(error)")
				}
			})
		}
	}
		
}

extension QuotesVC: UITableViewDataSource, UITableViewDelegate {

	func numberOfSections(in tableView: UITableView) -> Int {
		if isSsoAvailable {
			return existingQuotes.count > 0 ? 2 : 1
		} else {
			return 1
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isSsoAvailable {
			switch section {
			case 0:
				return 3
			case 1:
				return existingQuotes.count
			default:
				return 0
			}
		} else {
			return SessionManager.accessToken != nil ? 4 : 3
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 1 && isSsoAvailable {
			return 80.0
		}
		return 0.0
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 1 && isSsoAvailable {
			return tableView.dequeueReusableHeaderFooterView(withIdentifier: QuotePreviousQuotesHeaderView.identifier) as! QuotePreviousQuotesHeaderView
		}
		return nil
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if isSsoAvailable {
			switch indexPath.section {
			case 0:
				switch indexPath.row {
				case 0:
					if existingQuotes.count > 0 {
						return tableView.dequeueReusableCell(withIdentifier: QuoteTextCell.identifier, for: indexPath) as! QuoteTextCell
					} else {
						return tableView.dequeueReusableCell(withIdentifier: QuoteNoQuotesCell.identifier, for: indexPath) as! QuoteNoQuotesCell
					}
				case 1:
					let cell = tableView.dequeueReusableCell(withIdentifier: QuoteGetQuoteButtonCell.identifier, for: indexPath) as! QuoteGetQuoteButtonCell
					cell.delegate = self
					return cell
				case 2:
					let cell = tableView.dequeueReusableCell(withIdentifier: QuoteGetQuoteByPhoneCell.identifier, for: indexPath) as! QuoteGetQuoteByPhoneCell
					cell.delegate = self
					return cell
				default: break
				}
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: QuoteExistingQuoteCell.identifier, for: indexPath) as! QuoteExistingQuoteCell
				cell.quote = existingQuotes[indexPath.row]
				cell.delegate = self
				return cell
			default:
				break
			}
		} else { // SSO not available
			switch indexPath.row {
			case 0:
				let textCell = tableView.dequeueReusableCell(withIdentifier: QuoteTextCell.identifier, for: indexPath) as! QuoteTextCell
				textCell.label.text = NSLocalizedString("quotes.gettingafreequote", comment: "Getting a quick free quote from The General takes just a few simple steps. Let's get started!")
				return textCell
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: QuoteGetQuoteButtonCell.identifier, for: indexPath) as! QuoteGetQuoteButtonCell
				cell.delegate = self
				return cell
			case 2:
				let cell = tableView.dequeueReusableCell(withIdentifier: QuoteGetQuoteByPhoneCell.identifier, for: indexPath) as! QuoteGetQuoteByPhoneCell
				cell.delegate = self
				return cell
			case 3:
				let cell = tableView.dequeueReusableCell(withIdentifier: QuoteSeePreviousQuotesCell.identifier, for: indexPath) as! QuoteSeePreviousQuotesCell
				cell.delegate = self
				return cell
			default:
				break
			}
		}
		return UITableViewCell()
	}
	
}

extension QuotesVC: QuoteGetQuoteButtonCellDelegate, QuoteNavigatable {
	
	func didPressGetAQuote() {
        showGetAQuoteActionSheet(zipCode: zipCode)
	}
	
}

extension QuotesVC: QuoteGetQuoteByPhoneCellDelegate {
	
	func didPressGetQuoteByPhone() {
		showGetAQuoteByPhoneActionSheet()
	}
	
}

extension QuotesVC: QuoteExistingQuoteCellDelegate {
	
	func didTapCell(quote: QuoteResponse?) {
		guard let quote = quote, let quoteNumber = quote.quoteNumber else { return }
        continueApplication(quote: quote)
	}
}

extension QuotesVC: QuoteSeePreviousQuotesCellDelegate {

	func didTapSeePreviousQuotesCell() {
        showExistingQuotes()
	}
}
