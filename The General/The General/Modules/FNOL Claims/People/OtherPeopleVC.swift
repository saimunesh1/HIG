//
//  OtherPeopleVC.swift
//  The General
//
//  Created by Trevor Alyn on 11/3/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import MagicalRecord

class OtherPeopleVC: FNOLBaseVC {
	
	@IBOutlet weak var tableView: UITableView!
	
	public var viewModel: Questionnaire?
	
	private var otherPeople = [FNOLPerson]()
	private var sectionsList: [Section] = []
	private var showInstructions = true
	
	static func instantiate() -> PersonInfoVC {
		let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! PersonInfoVC
		return vc
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		navigationItem.title = NSLocalizedString("driverinfo.otherpeopleinvolved", comment: "Other people involved")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        
        if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
            topBarView.setCurrentPage(self.pageType)
        }
        
		loadFromCoreData {
			self.tableView.reloadData()
		}
	}
	
	func setupTableView() {
		registerNibs()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableViewAutomaticDimension
		let pageId = "other_people_involved"
		guard let list = self.viewModel?.getSectionList(pageID: pageId) else {
			return
		}
		self.sectionsList = list
	}
	
	private func loadFromCoreData(completion: (() -> Void)?) {
        // Load other people from Core Data
        // Make sure we only get the other people for the current claim who are in the accident
        let othersPredicate: NSPredicate = NSPredicate(format: "claim == %@", ApplicationContext.shared.fnolClaimsManager.activeClaim!)
        otherPeople = (FNOLPerson.mr_findAll(with: othersPredicate) as? [FNOLPerson]) ?? []
		otherPeople = otherPeople.filter({ $0.isOther == true && $0.isInAccident == true })
        completion?()
	}
	
	@objc override func keyboardWillShow(sender: NSNotification) {
		tableView.contentInset.bottom = keyboardHeight + defaultFooterHeight - 20.0 // For status bar?
	}
	
	@objc override func keyboardWillHide(sender: NSNotification) {
		tableView.contentInset.bottom = 0
	}
	
	func registerNibs() {
		tableView.register(AddButtonCell.nib, forCellReuseIdentifier: AddButtonCell.identifier)
		tableView.register(HeaderCell.nib, forCellReuseIdentifier: HeaderCell.identifier)
		tableView.register(InstructionsCell.nib, forCellReuseIdentifier: InstructionsCell.identifier)
		tableView.register(PersonNameCell.nib, forCellReuseIdentifier: PersonNameCell.identifier)
		tableView.register(TableFooterView.nib, forHeaderFooterViewReuseIdentifier: TableFooterView.identifier)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showPersonPickerVC" {
			if let vc = segue.destination as? PersonPickerVC {
				vc.isOwner = false
				vc.currentField = StateManager.instance.driverInfoField
				vc.personInfoType = .other
				showInstructions = false
			}
		} else if segue.identifier == "showPersonInfoVC" {
			if let vc = segue.destination as? PersonInfoVC {
				vc.isOwner = false
				vc.currentField = StateManager.instance.otherPeopleInfoField
				vc.personInfoType = .other
				vc.person = sender as? FNOLPerson
				vc.delegate = self
				vc.footerSaveButtonName = NSLocalizedString("driverinfo.saveString", comment: "Done")
			}
		} else if let vc = segue.destination as? SupportVC {
			vc.contextualHelpString = NSLocalizedString("contextualhelp.otherpeople", comment: "")
		}
	}
	
}

extension OtherPeopleVC: PersonInfoVCDelegate {
	
	func returnToOriginScreen() {
		navigationController?.popViewController(animated: true)
	}

	func didPick(person: FNOLPerson?) {
		if let person = person {
			person.isInAccident = true
			person.isOther = true
			ApplicationContext.shared.fnolClaimsManager.activeClaim?.addPerson(person)
		}
	}

}

extension OtherPeopleVC: FooterDelegate {
	
	func didTouchLeftButton() {
		showSaveQuitActionSheet()
		
		// Handles removing the top-bar when user navigates back
		if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
			self.supplementalNavigationController?.removeSupplementalView(topBarView, animated: false)
		}
	}
	
	func didTouchRightButton() {
		performSegue(withIdentifier: "showClaimReviewVC", sender: self)
	}
	
}

extension OtherPeopleVC: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var count = otherPeople.count
		count += 1 // For header cell
		count += 1 // For Add cell
		if showInstructions { count += 1 } // For instructions cell
		return count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 { // Header
			if let cell = tableView.dequeueReusableCell(withIdentifier: HeaderCell.identifier, for: indexPath) as? HeaderCell {
				cell.titleLabel.text = NSLocalizedString("otherpeople.additionalpeople", comment: "Additional people")
				return cell
			}
		} else if indexPath.row == 1 { // Add button
			if let cell = tableView.dequeueReusableCell(withIdentifier: AddButtonCell.identifier, for: indexPath) as? AddButtonCell {
				cell.titleLabel.text = NSLocalizedString("driverinfo.addotherperson", comment: "Add other person")
				return cell
			}
		} else if showInstructions && indexPath.row == 2 { // Instructions cell
			if let cell = tableView.dequeueReusableCell(withIdentifier: InstructionsCell.identifier, for: indexPath) as? InstructionsCell {
				return cell
			}
		} else { // Person cell
			if otherPeople.count > 0 {
				let instructionsOffset = (showInstructions ? 3 : 2)
				let otherPerson = otherPeople[indexPath.row - instructionsOffset]
				if let cell = tableView.dequeueReusableCell(withIdentifier: PersonNameCell.identifier, for: indexPath) as? PersonNameCell {
					cell.fnolPerson = otherPerson
					return cell
				}
			}
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return defaultHeaderHeight
		} else if indexPath.row == 1 {
			return defaultRowHeight
		} else if showInstructions && indexPath.row == 2 { // Instructions row
			return UITableViewAutomaticDimension
		}
		return defaultRowHeight
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableFooterView.identifier) as! TableFooterView
		footerCell.delegate = self
		footerCell.firstButtonText = NSLocalizedString("footer.savequit", comment: "Save/Quit")
		footerCell.nextButtonText = NSLocalizedString("footer.reviewclaim", comment: "Review claim")
		footerCell.nextButton.isEnabled = true
		return footerCell
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return defaultFooterHeight
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = UIColor.clear
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 0 { // Header
			return
		} else if indexPath.row == 1 { // Add button
			self.performSegue(withIdentifier: "showPersonPickerVC", sender: nil)
			return
		} else if indexPath.row == 2 && showInstructions { // Instructions
			return
		} else { // Person row
			let offset = (showInstructions ? 3 : 2)
			let person = otherPeople[indexPath.row - offset]
			performSegue(withIdentifier: "showPersonInfoVC", sender: person)
		}
	}

}


// MARK: - FNOLTopBarNavigatable
extension OtherPeopleVC: FNOLTopBarNavigatable {
    var pageType: FNOLTopBarPageType {
        return .otherPeople
    }
}
