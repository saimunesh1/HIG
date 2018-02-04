//
//  PeopleInMyVehicleVC.swift
//  The General
//
//  Created by Trevor Alyn on 10/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import MagicalRecord

public struct PersonRow {
	var labelText: String?
	var selected = false
	var person: FNOLPerson?
}

class PeopleInVehicleVC: PhotoPickViewController {

	@IBOutlet weak var tableView: UITableView!
	
	private var addressCell: AddressCell?
	private var driver: FNOLPerson?
	private var injuryRows = [Row]()
	private var isAttemptingToAddVehicle = false
	private var noDriverSelected = false
	private var passengerField: Field?
	private var passengers = [FNOLPerson]()
	private var peopleAnswers: NSMutableDictionary = [:]
	private var rows = [Row]()
	private var sectionsList: [Section] = []
	private var showInjuryRows = false
	private var showAddVehicleRow: Bool {
		if let numberOfVehicles = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "claim.vehicleCount") {
			return numberOfVehicles == "etc" || numberOfVehicles == "insured_vehicle_only"
		}
		return false
	}
	private var addVehicleRowIndex: Int {
		if passengers.count > 0 { return 2 }
		return 1
	}
	
	public var viewModel: Questionnaire?

	static func instantiate() -> PeopleInVehicleVC {
		let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! PeopleInVehicleVC
		return vc
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setUpTableView()
		setUpRowsFromQuestionnaire()
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender: )), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender: )), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        navigationItem.title = (ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex == 1) ? NSLocalizedString("people.peopleinmyvehicle", comment: "People in my vehicle") : NSLocalizedString("people.peopleinvehicle", comment: "People in vehicle X") + "\(ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex)"
		loadFromCoreData {
			self.tableView.reloadData()
		}
	}
	
	private func setUpRowsFromQuestionnaire() {
		rows = [Row]()
		for section in sectionsList {
			print(section)
			if let fields = section.fieldsArray {
				for field in fields {
					
					// Save passenger field becauase we need it so user can edit passenger
					if field.responseKey?.range(of: "passengers") != nil {
						passengerField = field
					}

					let row = Row(type: field.typeEnum!, value: "", responseKey: field.responseKey, field: field, index: nil)
					rows.append(row)
					if field.responseKey == "myVehicle.driver.whoWasDriving" {
						rows.append(Row(type: .address, value: " ", responseKey: nil, field: field, index: nil))
						rows.append(Row(type: .phoneNumber, value: " ", responseKey: nil, field: field, index: nil))
					}
					if field.label == "Injured?" {
						injuryRows = [Row]()
						if let subSubFields = field.subFieldsArray {
							for subSubField in subSubFields {
								injuryRows.append(Row(type: subSubField.typeEnum!, value: "", responseKey: subSubField.responseKey, field: subSubField, index: nil))
							}
						}
					}
				}
			}
		}
	}

	private func indexForRowWith(responseKey: String) -> Int? {
		for (index, row) in rows.enumerated() {
			if row.responseKey?.range(of: responseKey) != nil {
				return index
			}
		}
		return nil
	}
	
	func setUpTableView() {
		registerNibs()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableViewAutomaticDimension
		let pageId = "my_vehicle_people_details"
		guard let list = self.viewModel?.getSectionList(pageID: pageId) else {
			return
		}
		self.sectionsList = list
		guard let page = self.viewModel?.getPageForId(id: pageId) else {
			return
		}
		self.title = page.pageName
	}
	
	private func loadFromCoreData(completion: (() -> Void)?) {
        if let currentVehicle = ApplicationContext.shared.fnolClaimsManager.currentVehicle {
			let allPeopleInVehicle = currentVehicle.people?.allObjects as? [FNOLPerson] ?? []
			if let driver = allPeopleInVehicle.filter({ $0.isDriver == true }).first {
				self.driver = driver
			}
            if let injured = driver?.injured {
                switch injured {
                case Injured.yes.rawValue:
                    updateInjuryRows(index: 0)
                case Injured.no.rawValue:
                    updateInjuryRows(index: 1)
                case Injured.unsure.rawValue:
                    updateInjuryRows(index: 2)
                default:
                    break
                }
            }
			self.passengers = allPeopleInVehicle.filter({ $0.isPassenger == true && $0.isInAccident == true })
            completion?()
            return
        }
        completion?()
	}
	
	@objc override func keyboardWillShow(sender: NSNotification) {
		tableView.contentInset.bottom = keyboardHeight
	}
	
	@objc override func keyboardWillHide(sender: NSNotification) {
		tableView.contentInset.bottom = 0
	}

	func registerNibs() {
		tableView.register(DetailTableViewCell.nib, forCellReuseIdentifier: DetailTableViewCell.identifier)
		tableView.register(PeopleDriverCell.nib, forCellReuseIdentifier: PeopleDriverCell.identifier)
		tableView.register(PeoplePhoneNumberCell.nib, forCellReuseIdentifier: PeoplePhoneNumberCell.identifier)
		tableView.register(PeopleAddressCell.nib, forCellReuseIdentifier: PeopleAddressCell.identifier)
		tableView.register(DisclosureCell.nib, forCellReuseIdentifier: DisclosureCell.identifier)
		tableView.register(AddButtonCell.nib, forCellReuseIdentifier: AddButtonCell.identifier)
		tableView.register(AddressCell.nib, forCellReuseIdentifier: AddressCell.identifier)
		tableView.register(SegmentedControlTableViewCell.nib, forCellReuseIdentifier: SegmentedControlTableViewCell.identifier)
		tableView.register(PersonNameCell.nib, forCellReuseIdentifier: PersonNameCell.identifier)
        tableView.register(TableHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableHeaderView.identifier)
        tableView.register(TableFooterView.nib, forHeaderFooterViewReuseIdentifier: TableFooterView.identifier)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showPersonPickerVC" {
			if let vc  = segue.destination as? PersonPickerVC {
				vc.isOwner = false
				vc.currentField = StateManager.instance.driverInfoField
				vc.personPickerDelegate = self
				if let field = sender as? Field {
					vc.currentField = field
					if field.responseKey?.range(of: "passengers") != nil {
						vc.personInfoType = .passenger
					} else if field.responseKey?.range(of: "driver") != nil {
						vc.personInfoType = .driver
					}
				}
			}
		}
        else if segue.identifier == "showOtherVehicleVC" {
            if let vc = segue.destination as? OtherVehicleVC {
                vc.viewModel = self.viewModel
				ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex += 1

				// TODO: Update the top bar?
            }
        }
        else if segue.identifier == "showPickerVC" {
			if let field = sender as? Field, let vc = segue.destination as? PickerVC {
				vc.currentField = field
				vc.delegate = self
			}
		} else if segue.identifier == "personInfoSegueID", let passenger = sender as? FNOLPerson {
			if let vc = segue.destination as? PersonInfoVC {
				vc.currentField = passengerField
				vc.personInfoType = .passenger
				vc.person = passenger
				vc.footerSaveButtonName = NSLocalizedString("driverinfo.saveString", comment: "Done")
				vc.delegate = self
			}
		} else if let vc = segue.destination as? SupportVC {
			if let currentVehicle = ApplicationContext.shared.fnolClaimsManager.currentVehicle, currentVehicle.driver != nil {
				vc.contextualHelpString = NSLocalizedString("contextualhelp.peopleinmyvehicle.withdriver", comment: "")
			} else {
				vc.contextualHelpString = NSLocalizedString("contextualhelp.peopleinmyvehicle", comment: "")
			}
		}
	}
    
}

extension PeopleInVehicleVC: PersonInfoVCDelegate, PersonPickerVCDelegate {
	
	func returnToOriginScreen() {
		navigationController?.popViewController(animated: true)
	}
	
	func didPick(person: FNOLPerson?) {
		if let person = person {
			ApplicationContext.shared.fnolClaimsManager.activeClaim?.addPerson(person)
			if let currentVehicle = ApplicationContext.shared.fnolClaimsManager.currentVehicle {
				if person.isDriver {
					let allPeopleInVehicle = currentVehicle.people?.allObjects as? [FNOLPerson] ?? []
					allPeopleInVehicle.forEach({ $0.isDriver = false })
					person.isDriver = true
					person.isPassenger = false
					currentVehicle.driver = person
					PersistenceManager.shared.save()
				} else {
					person.isDriver = false
					person.isPassenger = true
					passengers.append(person)
				}
			}
		} else { // No driver
			noDriverSelected = true
			
			// Remove existing driver, if any
			if let driver = driver {
				driver.isDriver = false		
				driver.vehicle = nil
			}
			driver = nil
			if let currentVehicle = ApplicationContext.shared.fnolClaimsManager.currentVehicle {
				currentVehicle.driver = nil
			}
		}
		tableView.reloadData()
	}
	
}

extension PeopleInVehicleVC: PickerDelegate {
    func didAccidentPhotosPicked(imageArray: [FNOLImage]) {
    }

	func didPickSubField(value: String, displayValue: String, responseKey: String) {
        if responseKey.range(of: "injuryType") != nil {
            self.driver?.injuryType = value
        }
		navigationController?.popViewController(animated: true)
	}
	
}

extension PeopleInVehicleVC: DetailTableViewCellDelegate {
	
	func didFinishEditing(value: String, cell: DetailTableViewCell) {
		driver?.injuryDetails = value
	}
	
}

extension PeopleInVehicleVC: FooterDelegate {
	
	func didTouchLeftButton() {
		showSaveQuitActionSheet()
		
        // Handles removing the top-bar when user navigates back
        if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
            self.supplementalNavigationController?.removeSupplementalView(topBarView, animated: false)
        }
	}
	
	func didTouchRightButton() {
		formValidator.validate(self)
	}
	
}

extension PeopleInVehicleVC: SegmentedControlTableViewCellDelegate {
	func segmentValueChanged(field: Field, value: String) {
	}
	
	func didSwitch(index: Int, row: Row?) {
		if let row = row {
			if row.responseKey?.range(of: ".injured") != nil {
				if let _ = indexForRowWith(responseKey: ".injured") {
					updateInjuryRows(index: index)
					
					var injuredStatus: String?
					switch index {
					case 0:
						injuredStatus = Injured.yes.rawValue
					case 1:
						injuredStatus = Injured.no.rawValue
					case 3:
						injuredStatus = Injured.unsure.rawValue
					default:
						break
					}
					if let injuredStatus = injuredStatus {

						// Save to Core Data
						driver?.injured = injuredStatus
						
						// Save as key-value pair
						ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(injuredStatus, displayValue: nil, forResponseKey: "myVehicle.driver.injured")
					}
				}
			} else if row.responseKey?.range(of: "transportedFromScene") != nil {
				var transported: String?
				switch index {
				case 0:
					transported = TransportedFromScene.yes.rawValue
				case 1:
					transported = TransportedFromScene.no.rawValue
				case 3:
					transported = TransportedFromScene.dontKnow.rawValue
				default:
					break
				}

				if let driver = driver, let transported = transported {
                    driver.transportedFromScene = transported

                    // Save as key-value pair
                    ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(transported, displayValue: nil, forResponseKey: "myVehicle.driver.transportedFromScene")
				}
			}
		}
	}
	
	private func updateInjuryRows(index: Int) {
		let animation = UITableViewRowAnimation.fade
		if let injuredRowIndex = indexForRowWith(responseKey: ".injured") {
			var indexPaths = [IndexPath]()
			for i in 0..<injuryRows.count {
				indexPaths.append(IndexPath(row: injuredRowIndex + 1 + i, section: 0))
			}
			tableView.beginUpdates()
			if index == 0 { // Is injured
				// Splice in injuryRows
				if !showInjuryRows {
					showInjuryRows = true
					rows.insert(contentsOf: injuryRows, at: injuredRowIndex + 1)
					tableView.insertRows(at: indexPaths, with: animation)
				}
			} else { // Is not injured
				// Remove injuryRows
				if showInjuryRows {
					showInjuryRows = false
					rows.removeSubrange(injuredRowIndex + 1...injuredRowIndex + injuryRows.count)
					tableView.deleteRows(at: indexPaths, with: animation)
				}
			}
			tableView.endUpdates()
		}
	}
	
}

extension PeopleInVehicleVC: AddressLocationDelegate {

	func onTouchOnSave(addressInfo: FNOLAddressTemporary) {
		guard let cell = self.addressCell else { return }
		cell.accidentLocationAddress = addressInfo
		cell.addressValueLabel.text = addressInfo.asString()
		cell.accidentLocationAddress?.storeAccidentDetailsAddress()
		self.tableView.reloadData()
	}
	
	func didTouchOnHome() { }
	
	func didTouchOnLocation() { }
	
}

extension PeopleInVehicleVC: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		var sectionCount = 1
		if passengers.count > 0 { sectionCount += 1 }
		if showAddVehicleRow { sectionCount += 1 }
		return sectionCount
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return rows.count
		} else if showAddVehicleRow && section == addVehicleRowIndex {
			return 1
		} else if passengers.count > 0 && section > 0 {
			return passengers.count
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Handle "Add Vehicle" row
		if showAddVehicleRow && indexPath.section == addVehicleRowIndex {
			if let cell = tableView.dequeueReusableCell(withIdentifier: AddButtonCell.identifier, for: indexPath) as? AddButtonCell {
				cell.titleLabel.text = NSLocalizedString("myvehicle.toaddvehicle", comment: "Add vehicle")
				return cell
			}
			return UITableViewCell()

		// Handle passengers
		} else if indexPath.section == 1 && passengers.count > 0 {
			if let cell = tableView.dequeueReusableCell(withIdentifier: PersonNameCell.identifier, for: indexPath) as? PersonNameCell {
				cell.fnolPerson = passengers[indexPath.row]
				return cell
			}
			return UITableViewCell()

		} else if indexPath.section == 0 { // Handle top rows
		
			let row = rows[indexPath.row]
			switch row.type {
			case .driverPickList:
				if let cell = tableView.dequeueReusableCell(withIdentifier: PeopleDriverCell.identifier, for: indexPath) as? PeopleDriverCell {
					cell.item = row.field
					if let driver = driver {
						cell.person = driver
					} else {
						if noDriverSelected {
							cell.person = nil
							cell.valueLabel.text = NSLocalizedString("driverinfo.nodriver", comment: "No driver")
						}
					}
					// Hardcoding this because the API currently returns required = false
					cell.attributedText = Helper.requiredAttributedText(text:row.field!.label!)
					formValidator.registerField(cell.valueLabel, errorLabel: cell.errorLabel, rules: [RequiredRule()])
					return cell
				}
				
			case .address:
				if let cell = tableView.dequeueReusableCell(withIdentifier: PeopleAddressCell.identifier, for: indexPath) as? PeopleAddressCell {
					cell.item = row.field
					if let driver = driver {
						cell.person = driver
					}
					return cell
				}

			case .phoneNumber:
				if let cell = tableView.dequeueReusableCell(withIdentifier: PeoplePhoneNumberCell.identifier, for: indexPath) as? PeoplePhoneNumberCell {
					cell.item = row.field
					if let driver = driver {
						cell.person = driver
					}
					return cell
				}

			case .pickList: do {
				
				// Add passenger button
				if row.responseKey?.range(of: "passengers") != nil {
					if let cell = tableView.dequeueReusableCell(withIdentifier: AddButtonCell.identifier, for: indexPath) as? AddButtonCell {
						cell.item = row.field
						cell.titleLabel.text = NSLocalizedString("driverinfo.addpassenger", comment: "Add passenger")
						return cell
					}
					
				// Injured switches
				} else if row.responseKey?.range(of: "injured") != nil || row.responseKey?.range(of: "transportedFromScene") != nil {
					if let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedControlTableViewCell.identifier, for: indexPath) as? SegmentedControlTableViewCell {
						cell.row = row
						cell.field = row.field
						cell.cellSegmentControl.items = [NSLocalizedString("alert.yes", comment: "Yes"), NSLocalizedString("alert.no", comment: "No"), NSLocalizedString("alert.unsure", comment: "Unsure")]
						cell.delegate = self
						if row.responseKey?.range(of: "injured") != nil {
							if let driver = driver {
								cell.cellSegmentControl.isEnabled = true
								let injured = driver.injured ?? Injured.no.rawValue
								switch injured {
								case Injured.yes.rawValue:
									cell.cellSegmentControl.selectedIndex = 0
								case Injured.no.rawValue:
									cell.cellSegmentControl.selectedIndex = 1
								case Injured.unsure.rawValue:
									cell.cellSegmentControl.selectedIndex = 2
								default:
									break
								}
							} else {
								cell.cellSegmentControl.isEnabled = false
							}
						} else if row.responseKey?.range(of: "transportedFromScene") != nil {
							if let driver = driver, let transported = driver.transportedFromScene {
								switch transported {
								case TransportedFromScene.yes.rawValue:
									cell.cellSegmentControl.selectedIndex = 0
								case TransportedFromScene.no.rawValue:
									cell.cellSegmentControl.selectedIndex = 1
								case TransportedFromScene.dontKnow.rawValue:
									cell.cellSegmentControl.selectedIndex = 2
								default:
									break
								}
							} else {
								cell.cellSegmentControl.selectedIndex = 2
							}
						}
						return cell
					}
					
				// Injury Type picklist
				} else if row.responseKey?.range(of: "injuryType") != nil {
					let cell = tableView.dequeueReusableCell(withIdentifier: DisclosureCell.identifier, for: indexPath) as! DisclosureCell
					cell.titleLabel.text = row.field?.label
					if let driver = driver {
						if row.responseKey?.range(of: "transportedFromScene") != nil {
							cell.valueField.text = driver.transportedFromScene
						} else if row.responseKey?.range(of: "injuryType") != nil {
							cell.valueField.text = driver.injuryType
						}
					}
					return cell
				}
				}
				
			// Address
			case .addressType:
				if let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.identifier, for: indexPath) as? AddressCell {
					cell.field = row.field
					cell.selectionStyle = .none
					addressCell = cell
					return cell
				}
				
			// Injury description
			case .textBox:
				if let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.identifier, for: indexPath) as? DetailTableViewCell {
					cell.field = row.field
					cell.delegate = self
					
					// Fill in existing value, if any
					if let driver = driver {
						if let details = driver.injuryDetails, !details.isEmpty {
							cell.textView.text = details
							cell.textView.textColor = UIColor.black
						} else {
							cell.textView.text = row.field?.label
							cell.textView.textColor = UIColor.lightGray
						}
					} else {
						cell.textView.text = row.field?.label
						cell.textView.textColor = UIColor.lightGray
					}
					return cell
				}
			default:()
			}
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if showAddVehicleRow && indexPath.section == addVehicleRowIndex {
			return defaultRowHeight
		} else if passengers.count > 0 && indexPath.section == 1 {
			return defaultRowHeight
		} else if indexPath.section == 0 {
			let row = rows[indexPath.row]
			switch row.type {
			case .driverPickList:
				return UITableViewAutomaticDimension
			case .pickList:
                if let responseKey = row.responseKey, responseKey.contains("injured") || responseKey.contains("transportedFromScene") {
                    return UITableViewAutomaticDimension
                }
				return defaultRowHeight
			case .addressType: return addressRowHeight
			case .textBox: return defaultFooterHeight
			case .toggleType: return UITableViewAutomaticDimension
			default:
				return UITableViewAutomaticDimension
			}
		}
		return 0.0
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let currentSection = sectionsList[section]
		if let _ = currentSection.sectionName {
			let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.identifier) as! TableHeaderView
			let border = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0.5))
			border.backgroundColor = .tgGray
			headerCell.addSubview(border)
			let title = currentSection.sectionName?.lowercased()
			headerCell.headerLabel?.text = title?.firstUppercased
			return headerCell
		}
		return nil
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = UIColor.clear
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let  footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableFooterView.identifier) as! TableFooterView
		footerCell.delegate = self
		
		if let vehicleCount = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "claim.vehicleCount") {
			let count = Int(vehicleCount) ?? -1
			let allVehiclesRecorded = (count > 0 && count == ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex)
			if vehicleCount == "insured_vehicle_only" || vehicleCount == "etc" || vehicleCount == "1" || allVehiclesRecorded {
				footerCell.nextButtonText = NSLocalizedString("otherpeople.tootherpeople", comment: "To other people")
			} else {
				footerCell.nextButtonText = NSLocalizedString("otherpeople.toothervehicle", comment: "To other vehicle")
			}
		}
        return section == numberOfSections(in: self.tableView) - 1 ? footerCell : nil
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.0
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return (section == numberOfSections(in: self.tableView) - 1) ? defaultFooterHeight : 0.0
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if showAddVehicleRow && indexPath.section == addVehicleRowIndex {
			isAttemptingToAddVehicle = true
			formValidator.validate(self)
		} else if indexPath.section == 0 {
			let row = rows[indexPath.row]
			switch row.type {
			case .pickList:
				if row.responseKey?.range(of: "injuryType") != nil {
					performSegue(withIdentifier: "showPickerVC", sender: row.field)
				} else if row.responseKey?.range(of: "passengers") != nil {
					performSegue(withIdentifier: "showPersonPickerVC", sender: row.field)
				}
			case .driverPickList:
				performSegue(withIdentifier: "showPersonPickerVC", sender: row.field)
			default:()
			}
		} else { // User tapped a passenger
			let passenger = passengers[indexPath.row]
			performSegue(withIdentifier: "personInfoSegueID", sender: passenger)
		}
	}
	
}

extension PeopleInVehicleVC: UIValidationDelegate {
	
	func validationSuccessful() {
		if isAttemptingToAddVehicle {
			isAttemptingToAddVehicle = false
			let alert = UIAlertController(
				title: nil,
				message: NSLocalizedString("alert.addvehicle", comment: "Are you sure you want to add a vehicle to this claim?"),
				preferredStyle: UIAlertControllerStyle.alert
			)
			alert.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", comment: "Cancel"), style: .default, handler: nil))
			alert.addAction(UIAlertAction(title: NSLocalizedString("alert.yes", comment: "Yes"), style: .cancel, handler: { [weak self] (alert) -> Void in
				self?.performSegue(withIdentifier: "showOtherVehicleVC", sender: self)
			}))
			present(alert, animated: true, completion: nil)
		} else { // Next screen
			if let vehicleCount = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "claim.vehicleCount") {
				if let count = Int(vehicleCount) {
					if ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex < count {
						self.performSegue(withIdentifier: "showOtherVehicleVC", sender: self)
					} else {
						// All vehicles recorded
						self.performSegue(withIdentifier: "showOtherPeopleVC", sender: self)
					}
				} else if vehicleCount == "insured_vehicle_only" || vehicleCount == "etc" {
					self.performSegue(withIdentifier: "showOtherPeopleVC", sender: self)
				}
			}
		}
	}
	
	func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)]) {
		self.tableView.reloadData()
	}
	
}
