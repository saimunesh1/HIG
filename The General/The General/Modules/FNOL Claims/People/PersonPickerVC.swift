//
//  PersonPickerVC.swift
//  The General
//
//  Created by Trevor Alyn on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import MagicalRecord

protocol PersonPickerVCDelegate {
	func didPick(person: FNOLPerson?)
}

class PersonPickerVC: PickerVC {

	public var isOwner = true
	public var personInfoType = PersonInfoType.driver

	private var rows = [PersonRow]()

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpPersonRows()
		if isOwner {
			navigationItem.title = NSLocalizedString("driverInfo.ownerinfo", comment: "Owner information")
		} else {
			switch personInfoType {
			case .driver:
				navigationItem.title = NSLocalizedString("driverinfo.driverinfo", comment: "Driver information")
			case .passenger:
				navigationItem.title = NSLocalizedString("driverinfo.passengerinfo", comment: "Passenger information")
			case .other:
				navigationItem.title = NSLocalizedString("driverinfo.otherpeopleinvolved", comment: "Other people involved")
			case .owner: // Should never happen
				break
			}
		}
    }
	
	private func setUpPersonRows() {
		guard let activeClaim = ApplicationContext.shared.fnolClaimsManager.activeClaim else { return }
		let predicate: NSPredicate = NSPredicate(format: "claim == %@", activeClaim)
		let allFnolPeople = (FNOLPerson.mr_findAll(with: predicate) as? [FNOLPerson]) ?? []
		for person in allFnolPeople {
			let firstName = person.firstName ?? ""
			let lastName = person.lastName ?? ""
			let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
			rows.append(PersonRow(labelText: fullName, selected: false, person: person))
		}
		// Additional row for No Driver
		if !isOwner && personInfoType == .driver {
			rows.append(PersonRow(labelText: NSLocalizedString("driverinfo.nodriver", comment: "No driver"), selected: false, person: nil))
		}

		// Additional row for creating new person
		rows.append(PersonRow(labelText: NSLocalizedString("driverInfo.otherperson", comment: "Other person, not on policy"), selected: false, person: nil))
	}

}

extension PersonPickerVC {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (rows.count)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PickerViewCell.identifier, for: indexPath) as! PickerViewCell
		cell.titleLabel.text = rows[indexPath.row].labelText?.capitalized
		cell.checkImageView.isHidden = !rows[indexPath.row].selected
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if !isOwner && personInfoType == .driver && indexPath.row == rows.count - 2 { // No driver
			personPickerDelegate?.didPick(person: nil)
			self.navigationController?.popViewController(animated: true)
		} else if indexPath.row == rows.count - 1 { // Adding a new person
		
			if isOwner {
				// The user is picking a vehicle owner, and has tapped "Someone not on this policy."
				let alertController = UIAlertController(title: nil, message: NSLocalizedString("driverinfo.wasthispersondriving", comment: "Was this person driving?"), preferredStyle: .alert)
				let cancelAction = UIAlertAction(title: NSLocalizedString("alert.no", comment: "No"), style: .destructive) { (action) in
					self.showPersonInfoVC(personInfoType: .owner, isOwner: true)
				}
				alertController.addAction(cancelAction)
				let confirmAction = UIAlertAction(title: NSLocalizedString("alert.yes", comment: "Yes"), style: .default) { (action) in
					self.showPersonInfoVC(personInfoType: .driver, isOwner: true)
				}
				alertController.addAction(confirmAction)
				present(alertController, animated: true, completion: nil)
				
			} else { // This isn't the Owner flow
				showPersonInfoVC(personInfoType: personInfoType, isOwner: false)
			}

		} else { // Choosing an existing person
			
			if isOwner {
				
				// The user is picking a vehicle owner, and has tapped someone on the policy
				let alertController = UIAlertController(title: nil, message: NSLocalizedString("driverinfo.wasthispersondriving", comment: "Was this person driving?"), preferredStyle: .alert)
				let cancelAction = UIAlertAction(title: NSLocalizedString("alert.no", comment: "No"), style: .destructive) { (action) in
					self.savePerson(indexPath: indexPath, isDriver: false) {
						self.navigationController?.popViewController(animated: true)
					}
				}
				alertController.addAction(cancelAction)
				let confirmAction = UIAlertAction(title: NSLocalizedString("alert.yes", comment: "Yes"), style: .default) { (action) in
					self.savePerson(indexPath: indexPath, isDriver: true) {
						self.navigationController?.popViewController(animated: true)
					}
				}
				alertController.addAction(confirmAction)
				present(alertController, animated: true, completion: nil)
				
			} else { // Not the owner flow
				
				for (index, _) in rows.enumerated() {
					if index != indexPath.row {
						rows[index].selected = false
					} else {
						rows[index].selected = true
					}
				}
				savePerson(indexPath: indexPath, isDriver: personInfoType == .driver) {
					self.navigationController?.popViewController(animated: true)
				}
			}
		}
	}
	
	private func savePerson(indexPath: IndexPath, isDriver: Bool, completion: (() -> Void)?) {
		if let person = rows[indexPath.row].person {
            person.isDriver = isDriver
            person.isOwner = self.isOwner
            person.isPassenger = (self.personInfoType == .passenger)
            person.isOther = (self.personInfoType == .other)
            person.vehicle = ApplicationContext.shared.fnolClaimsManager.currentVehicle
			if person.isDriver || person.isPassenger {
				person.isInAccident = true
			}
			personPickerDelegate?.didPick(person: person)
            completion?()
		}
	}
	
	private func showPersonInfoVC(personInfoType: PersonInfoType, isOwner: Bool) {
		let personInfoVC = UIStoryboard(name: "FNOL", bundle: nil).instantiateViewController(withIdentifier: "PersonInfoVC") as! PersonInfoVC
		if personInfoType == .other {
			personInfoVC.currentField = StateManager.instance.otherPeopleInfoField
		} else {
			personInfoVC.currentField = self.currentField
		}
		personInfoVC.isOwner = isOwner
		personInfoVC.delegate = self
		personInfoVC.personInfoType = personInfoType
		self.navigationController?.pushViewController(personInfoVC, animated: true)
	}
	
}
