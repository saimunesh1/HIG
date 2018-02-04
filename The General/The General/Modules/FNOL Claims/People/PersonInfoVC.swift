//
//  PersonInfoVC.swift
//  The General
//
//  Created by Trevor Alyn on 10/31/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public enum PersonInfoType {
	case driver
	case passenger
	case owner
	case other
}

// This is necessary because we have to do some manipulation of the fields;
// we can't just use them as they come in the Questionnaire.
public struct Row {
	var type: CellType
	var value = ""
	var responseKey: String?
	var field: Field?
	var index: Int? // Only for segmented controls
}

public enum PersonPhotoType: String {
	case license
	case insurance
}
						
protocol PersonInfoVCDelegate {
	func returnToOriginScreen()
	func didPick(person: FNOLPerson?)
}

class PersonInfoVC: PhotoPickViewController, OverlayNavigatable {

	@IBOutlet weak var tableView: UITableView!
		
	private var currentPhotoCellType: PersonPhotoType?
	private var effectiveDatesStartCellExpanded: Bool = false
	private var effectiveDatesEndCellExpanded: Bool = false
	private var footerCell: TableFooterView?
	private var hidePersonalInfoCells = false
	private var injuryRows = [Row]()
	private var witnessRows = [Row]()
	private var showInjuryRows = false
	private var tempPerson: FNOLPersonTemporary?
	private var insuranceVerificationImage: UIImage?
	private var personalInformationImage: UIImage?
	private var personInfoRows = [Row]()
	private let personInfoRowResponseKeys = ["firstName", "lastName", "phoneNumber", "street", "addressDetail1", "city", "state", "zip", "country"]
	private var personDetailsAnswers: NSMutableDictionary = [:]
	private var rows = [Row]()
	private var subFields: [Field]?

	public var delegate: PersonInfoVCDelegate?
	public var footerSaveButtonName: String?
	public var personInfoType: PersonInfoType = .driver
	public var isOwner = false
	public var person: FNOLPerson?
	public var personIsFromQuestionnaire = false
	public var titleText = ""
	public var currentField: Field? {
		didSet {
			subFields = currentField?.subFieldsArray
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()

		if isOwner {
			navigationItem.title = NSLocalizedString("driverInfo.ownerinfo", comment: "Owner information")
		} else {
			switch personInfoType {
			case .driver:
				navigationItem.title = NSLocalizedString("driverinfo.driverinfo", comment: "Driver information")
			case .passenger:
				navigationItem.title = NSLocalizedString("driverinfo.passengerinfo", comment: "Passenger information")
			case .other:
				navigationItem.title = NSLocalizedString("driverinfo.otherperson", comment: "Person involved")
			case .owner: // Should never happen
				break
			}
		}
		
		// If we didn't get an FNOLPerson from the previous VC, create one
		if let person = person {
			tempPerson = person.temporaryCopy()
		} else {
			tempPerson = FNOLPersonTemporary()
		}

		if let isFromQuestionnaire = tempPerson?.isFromQuestionnaire {
			personIsFromQuestionnaire = isFromQuestionnaire
		}
		setUpRows()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
		if personInfoType == .passenger {
			showPassengerOverlayIfNecessary()
		}
	}
	
	private func setUpRows() {
		rows = [Row]()
		if let fields = subFields {
			for field in fields {
				if field.typeEnum == .textBox ||
					field.typeEnum == .pictureType ||
					field.typeEnum == .datePicker ||
					field.typeEnum == .pickList {
					if field.label != "Injured?" {
						if field.responseKey?.range(of: "insurance") == nil {
							let row = Row(type: field.typeEnum!, value: "", responseKey: field.responseKey, field: field, index: nil)
							rows.append(row)
							
							// If this is a personal info row, also add it to personInfoRows so it can be shown/hidden
							if let key = row.responseKey, includesPersonInfoKey(testKey: key) {
								personInfoRows.append(row)
							}
							
						} else if personInfoType == .driver { // Add insurance rows only for drivers
							rows.append(Row(type: field.typeEnum!, value: "", responseKey: field.responseKey, field: field, index: nil))

							// If this is an Effective Dates row for insurance, add another row below it for the end date
							if field.responseKey?.range(of: "insurance.effectiveDates") != nil {
								
								// Not configuring this row, because currently we don't have a claim submission field for this second date
								let row = Row(type: field.typeEnum!, value: "", responseKey: nil, field: field, index: nil)
								rows.append(row)
							}
						}
					} else {
						// Only show the "Injured?" rows when this is NOT the owner of the car
						if !isOwner {
							rows.append(Row(type: field.typeEnum!, value: "", responseKey: field.responseKey, field: field, index: nil))
							injuryRows = [Row]()
							witnessRows = [Row]()
							if let subSubFields = field.subFieldsArray {
								for subSubField in subSubFields {
									let row = Row(type: subSubField.typeEnum!, value: "", responseKey: subSubField.responseKey, field: subSubField, index: nil)
									if subSubField.responseKey?.range(of: "isThisPersonWitness") != nil {
										witnessRows.append(row)
									} else {
										injuryRows.append(row)
									}
								}
							}
							if tempPerson?.injured == Injured.yes.rawValue {
								rows.insert(contentsOf: injuryRows, at: 2)
							} else if personInfoType == .other {
								rows.insert(contentsOf: witnessRows, at: 2)
							}
						}
					}
				} else if field.typeEnum == .toggleType, personInfoType != .driver {
					let row = Row(type: field.typeEnum!, value: field.label ?? "", responseKey: field.responseKey, field: field, index: nil)
					rows.append(row)
				}
			}
			
			// Get images, if any
			if let licenseImage = person?.licenseImage?.image {
				personalInformationImage = licenseImage
				let responseKey = PersonPhotoType.license.rawValue
				let licenseRow = Row(type: .photoCell, value: "", responseKey: responseKey, field: nil, index: nil)
				var insuranceRowIndex = -1
				for (index, subField) in subFields!.enumerated() {
					if subField.responseKey?.range(of: "insurance.picture") != nil {
						insuranceRowIndex = index
					}
				}
				if insuranceRowIndex == -1 {
					insuranceRowIndex = rows.count
				}
				rows.insert(licenseRow, at: insuranceRowIndex)
			}
			if let insuranceImage = person?.insuranceImage?.image {
				insuranceVerificationImage = insuranceImage
				let responseKey = PersonPhotoType.insurance.rawValue
				let insuranceRow = Row(type: .photoCell, value: "", responseKey: responseKey, field: nil, index: nil)
				rows.insert(insuranceRow, at: rows.count)
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

	private func includesPersonInfoKey(testKey: String) -> Bool {
		for key in personInfoRowResponseKeys {
			if testKey.range(of: key) != nil {
				return true
			}
		}
		return false
	}
	
	private func validate() -> Bool {
		guard hidePersonalInfoCells == false else {
			return true
		}
		return tempPerson?.firstName?.isEmpty == false && tempPerson?.lastName?.isEmpty == false
	}
	
	func setupTableView() {
		registerNibs()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableViewAutomaticDimension
	}
	
	static func instantiate() -> PersonInfoVC {
		let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! PersonInfoVC
		return vc
	}
	
	@objc override func keyboardWillShow(sender: NSNotification) {
		tableView.contentInset.bottom = keyboardHeight - 10.0
	}
	
	@objc override func keyboardWillHide(sender: NSNotification) {
		tableView.contentInset.bottom = 0
	}
	
	func registerNibs() {
		tableView.register(HeaderCell.nib, forCellReuseIdentifier: HeaderCell.identifier)
		tableView.register(SegmentedControlTableViewCell.nib, forCellReuseIdentifier: SegmentedControlTableViewCell.identifier)
		tableView.register(InfoTableViewCell.nib, forCellReuseIdentifier: InfoTableViewCell.identifier)
		tableView.register(DatePickerCell.nib, forCellReuseIdentifier: DatePickerCell.identifier)
		tableView.register(DetailTableViewCell.nib, forCellReuseIdentifier: DetailTableViewCell.identifier)
		tableView.register(TableFooterView.nib, forHeaderFooterViewReuseIdentifier: TableFooterView.identifier)
		tableView.register(PeoplePhotoCell.nib, forCellReuseIdentifier: PeoplePhotoCell.identifier)
		tableView.register(DisclosureCell.nib, forCellReuseIdentifier: DisclosureCell.identifier)
	}
	
	@objc override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		picker.dismiss(animated: true, completion: nil)
		if let photoChosen = currentPhotoCellType {
			var image: UIImage?
			if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
				image = editedImage
			} else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
				image = originalImage
			}
			if let pickedImage = image {				
				if photoChosen == .license {
					personalInformationImage = pickedImage
				} else if photoChosen == .insurance {
					insuranceVerificationImage = pickedImage
				}
				addPhotoCell(type: photoChosen)
			}
		}
	}
	
	private func addPhotoCell(type: PersonPhotoType) {
		let existingSubfield = subFields!.filter { $0.responseKey == type.rawValue }
		if existingSubfield.count < 1 {
			
			var insuranceRowIndex = -1
			for (index, subField) in subFields!.enumerated() {
				if subField.responseKey?.range(of: "insurance.picture") != nil {
					insuranceRowIndex = index
				}
			}
			if insuranceRowIndex == -1 {
				insuranceRowIndex = rows.count
			}
			
			var responseKey: String?
			var insertLocation: Int?
			if type == .license {
				responseKey = PersonPhotoType.license.rawValue
				insertLocation = insuranceRowIndex
			} else if type == .insurance {
				responseKey = PersonPhotoType.insurance.rawValue
				insertLocation = rows.count
			}
			
			if let location = insertLocation {
				let row = Row(type: .photoCell, value: "", responseKey: responseKey, field: nil, index: nil)
				rows.insert(row, at: location)
				tableView.reloadData()
			}
		}
	}
	
	private func showDiscardWarning(userConfirmed: @escaping () -> Void) {
		var discardString = NSLocalizedString("people.discard", comment: "Discard this person's info?")
		switch personInfoType {
		case .driver:
			discardString = NSLocalizedString("driverinfo.discarddriverinfo", comment: "Discard driver info?")
		case .passenger:
			discardString = NSLocalizedString("passengerinfo.discardpassengerinfo", comment: "Discard passenger info?")
		default:
			break
		}
		let alertController = UIAlertController(title: nil, message: discardString, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: NSLocalizedString("alert.no", comment: "No"), style: .destructive) { (action) in
			// Do nothing
		}
		alertController.addAction(cancelAction)
		let confirmAction = UIAlertAction(title: NSLocalizedString("alert.yes", comment: "Yes"), style: .default) { (action) in
			// No need to delete tempPerson
			userConfirmed()
		}
		alertController.addAction(confirmAction)
		present(alertController, animated: true, completion: nil)

	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showPickerVC" {
			let vc  = segue.destination as! PickerVC
			vc.delegate = self
			vc.currentField = sender as? Field
		} else if segue.identifier == "showStatesVC" {
			let vc  = segue.destination as! StatePickerVC
			vc.callback = { [weak self] (value) in
				guard let weakSelf = self else { return }
				weakSelf.tempPerson?.state = value
			}
		} else if segue.identifier == "showCountryVC" {
			let vc  = segue.destination as! CountryPickVC
			vc.callback = { [weak self] (value) in
				guard let weakSelf = self else { return }
				weakSelf.tempPerson?.country = value
			}
		}
	}
	
	override func goBack(segue: UIStoryboardSegue) {
		showDiscardWarning {
			super.goBack(segue: segue)
		}
	}

}

extension PersonInfoVC: PickerDelegate {
    func didAccidentPhotosPicked(imageArray: [FNOLImage]) {
        
	}

	func didPickSubField(value: String, displayValue: String, responseKey: String) {
		tempPerson?.update(value: value, forResponseKey: responseKey)
		ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: responseKey)
		navigationController?.popViewController(animated: true)
	}
	
}

extension PersonInfoVC: DetailTableViewCellDelegate {
	
	func didFinishEditing(value: String, cell: DetailTableViewCell) {
		if let responseKey = cell.field?.responseKey {
			tempPerson?.update(value: value, forResponseKey: responseKey)
		}
	}
	
}

extension PersonInfoVC: InfoTableViewCellDelegate {
	
	func didUpdate(index: Int, text: String) {
		rows[index].value = text
		if let responseKey = rows[index].responseKey {
			tempPerson?.update(value: text, forResponseKey: responseKey)
		}
		if let footerCell = footerCell {
			footerCell.nextButton.isEnabled = validate()
		}
	}
	
	func didFinishUpdating(index: Int, text: String) {
		if let responseKey = rows[index].responseKey {
			tempPerson?.update(value: text, forResponseKey: responseKey)
		}
	}

}

extension PersonInfoVC: DatePickerCellDelegate {

	func didPickDate(date: Date, field: Field?, row: Row?) {
		if let responseKey = row?.responseKey {
			tempPerson?.update(value: date, forResponseKey: responseKey)
		}
		tableView.reloadData()
	}

}

extension PersonInfoVC: DisclosureCellDelegate {

	func didUpdate(text: String, forResponseKey responseKey: String) {
		tempPerson?.update(value: text, forResponseKey: responseKey)
	}

}

extension PersonInfoVC: SegmentedControlTableViewCellDelegate {
	func segmentValueChanged(field: Field, value: String) {
	}
	
	func didSwitch(index: Int, row: Row?) {
		if let row = row {
			let animation = UITableViewRowAnimation.fade
			if row.responseKey?.range(of: ".dontHaveInfo") != nil || row.responseKey?.range(of: ".haveOwnerInfo") != nil || row.responseKey?.range(of: "haveInfo") != nil {
				var start = isOwner ? 1 : 2
				if showInjuryRows { start += injuryRows.count }
				if personInfoType == .other { start -= 1 }
				var personInfoIndexPaths = [IndexPath]()
				for i in 0..<personInfoRows.count {
					personInfoIndexPaths.append(IndexPath(row: start + i, section: 0))
				}
				if index == 0 { // Has personal info
					// Splice in personal info rows
					if hidePersonalInfoCells == true {
						hidePersonalInfoCells = false
						if row.responseKey?.range(of: ".dontHaveInfo") != nil { // Passenger
							rows.insert(contentsOf: personInfoRows, at: start + 1)
						} else if row.responseKey?.range(of: ".haveOwnerInfo") != nil { // Owner
							rows.insert(contentsOf: personInfoRows, at: start)
						} else if row.responseKey?.range(of: "haveInfo") != nil { // Other Person
							if showInjuryRows {
								rows.insert(contentsOf: personInfoRows, at: start + 2)
							} else {
								rows.insert(contentsOf: personInfoRows, at: start + 3)
							}
						}
						tableView.insertRows(at: personInfoIndexPaths, with: animation)
					}
				} else { // Doesn't have personal info
					// Remove personal info rows
					if !hidePersonalInfoCells {
						hidePersonalInfoCells = true
						if row.responseKey?.range(of: ".dontHaveInfo") != nil { // Passenger
							rows.removeSubrange(start + 1...start + personInfoIndexPaths.count)
						} else if row.responseKey?.range(of: ".haveOwnerInfo") != nil { // Owner
							rows.removeSubrange(start...start + personInfoIndexPaths.count - 1)
						} else if row.responseKey?.range(of: ".haveInfo") != nil { // Other person
							if showInjuryRows {
								rows.removeSubrange(start + 2...start + personInfoIndexPaths.count + 1)
							} else {
								rows.removeSubrange(start + 3...start + personInfoIndexPaths.count + 2)
							}
						}
						tableView.deleteRows(at: personInfoIndexPaths, with: animation)
					}
				}
				if let footerCell = footerCell {
					footerCell.nextButton.isEnabled = validate()
				}
			} else if row.responseKey?.range(of: ".injured") != nil {
				if let injuredRowIndex = indexForRowWith(responseKey: ".injured") {
					var personInfoIndexPaths = [IndexPath]()
					for i in 0..<injuryRows.count {
						personInfoIndexPaths.append(IndexPath(row: injuredRowIndex + 1 + i, section: 0))
					}
					tableView.beginUpdates()
					if index == 0 { // Is injured
						// Splice in injuryRows
						if !showInjuryRows {
							showInjuryRows = true
							if personInfoType == .other {
								rows.remove(at: injuredRowIndex + 1)
								tableView.deleteRows(at: [IndexPath(row: injuredRowIndex + 1, section: 0)], with: animation)
							}
							rows.insert(contentsOf: injuryRows, at: injuredRowIndex + 1)
							tableView.insertRows(at: personInfoIndexPaths, with: animation)
						}
					} else { // Is not injured
						// Remove injuryRows
						if showInjuryRows {
							showInjuryRows = false
							rows.removeSubrange(injuredRowIndex + 1...injuredRowIndex + injuryRows.count)
							tableView.deleteRows(at: personInfoIndexPaths, with: animation)
							if personInfoType == .other {
								rows.insert(contentsOf: witnessRows, at: injuredRowIndex + 1)
								tableView.insertRows(at: [IndexPath(row: injuredRowIndex + 1, section: 0)], with: animation)
							}
						}
					}

                    self.tempPerson?.injured = Injured.allValues[index]
                    
					tableView.endUpdates()
				}
			} else if row.responseKey?.range(of: "transportedFromScene") != nil {
				let newValue = TransportedFromScene.allValues[index]
				if let responseKey = row.responseKey {
					tempPerson?.update(value: newValue, forResponseKey: responseKey)
				}
			} else if row.responseKey?.range(of: "isThisPersonWitness") != nil {
				let newValue = IsWitness.allValues[index]
				if let responseKey = row.responseKey {
					tempPerson?.update(value: newValue, forResponseKey: responseKey)
				}
			}
		}
	}
	
}

extension PersonInfoVC: FooterDelegate {
	
	func didTouchLeftButton() { // Cancel
		showDiscardWarning {
			self.delegate?.returnToOriginScreen()
		}
	}
	
	func didTouchRightButton() { // Add person
		savePerson {
			if let person = self.person {
				self.delegate?.didPick(person: person)
			}
			self.delegate?.returnToOriginScreen()
		}
	}
	
}

extension PersonInfoVC { // Core Data
	
	private func savePerson(completion: (() -> Void)?) {
		tempPerson?.isOwner = self.isOwner
		tempPerson?.isPassenger = self.personInfoType == .passenger
		tempPerson?.isOther = self.personInfoType == .other
		if personInfoType == .driver {
			// TODO: If there's already a driver for this vehicle, clear their isDriver flag
			tempPerson?.isDriver = true
		}
		if var tempPerson = self.tempPerson {
			if (tempPerson.firstName == nil || tempPerson.firstName!.isEmpty) && (tempPerson.lastName == nil || tempPerson.lastName!.isEmpty) {
				tempPerson.firstName = "Unknown"
				tempPerson.lastName = "Unknown"
			}
            if person == nil {
                person = FNOLPerson.mr_createEntity()!
            }
            person!.updateFromTemporaryCopy(temp: tempPerson)
			
			if let licenseImage = self.personalInformationImage {
               	person?.setImage(licenseImage, imageType: .license)
            }
            if let insuranceImage = self.insuranceVerificationImage {
                person?.setImage(insuranceImage, imageType: .insurance)
            }
            person?.claim = ApplicationContext.shared.fnolClaimsManager.activeClaim
            person?.isInAccident = true
            if personInfoType != .other {
                person?.vehicle = ApplicationContext.shared.fnolClaimsManager.currentVehicle
            }
			if personInfoType == .driver {
                ApplicationContext.shared.fnolClaimsManager.currentVehicle?.driver = person
            }
			delegate?.didPick(person: person!)
            completion?()
		}
	}
}

extension PersonInfoVC { // Photos
	
	func didTapOnTakePicture() {
		let alert: UIAlertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
		let messageFont = [NSAttributedStringKey.font: UIFont.boldTitle]
		let messageAttrString = NSMutableAttributedString(string: NSLocalizedString("alert.accident.title", comment: ""), attributes: messageFont)
		alert.setValue(messageAttrString, forKey: "attributedMessage")
        let cameraAction = UIAlertAction(title: NSLocalizedString("alert.accident.camera", comment: ""), style: UIAlertActionStyle.default) {[weak self]  UIAlertAction in
            guard let weakSelf = self else { return }
            weakSelf.cameraAllowsAccessToApplicationCheck()
		}
        let gallaryAction = UIAlertAction(title: NSLocalizedString("alert.accident.gallery", comment: ""), style: UIAlertActionStyle.default) {[weak self]  UIAlertAction in
            guard let weakSelf = self else { return }
            weakSelf.photoLibraryAvailabilityCheck()
		}
		let cancelAction = UIAlertAction(title: NSLocalizedString("alert.cancel", comment: ""), style: UIAlertActionStyle.cancel) {
			UIAlertAction in
		}
		alert.addAction(cameraAction)
		alert.addAction(gallaryAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true, completion: nil)
	}
	
}

extension PersonInfoVC: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rows.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = rows[indexPath.row]
		switch row.type {
			
		// Header
		case .pictureType:
			if let cell = tableView.dequeueReusableCell(withIdentifier: HeaderCell.identifier, for: indexPath) as? HeaderCell {
				cell.field = row.field
				if indexPath.row == 0 {
					cell.titleLabel.text = NSLocalizedString("driverinfo.personalinformation", comment: "Personal information")
				}
				cell.headerImageView.isHidden = false
				return cell
			}
			
		// Don't Have Info toggle
		case .toggleType:
			if let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedControlTableViewCell.identifier, for: indexPath) as? SegmentedControlTableViewCell {
				cell.cellSegmentControl.items = [NSLocalizedString("alert.yes", comment: "Yes"), NSLocalizedString("alert.no", comment: "No")]
				cell.delegate = self
				cell.row = row
				if row.responseKey?.range(of: ".dontHaveInfo") != nil || row.responseKey?.range(of: ".haveOwnerInfo") != nil || row.responseKey?.range(of: "haveInfo") != nil {
					cell.cellSegmentControl.selectedIndex = hidePersonalInfoCells ? 1 : 0
					// Hardcoding this because it's confusing as it is in the Questionnaire
					if row.responseKey?.range(of: ".dontHaveInfo") != nil {
						cell.cellLabel.text = NSLocalizedString("passengerinfo.doyouhavepassengerinfo", comment: "Do you have the passenger's info?")
					} else if row.responseKey?.range(of: "haveOwnerInfo") != nil {
						cell.cellLabel.text = NSLocalizedString("ownerinfo.doyouhaveownerinfo", comment: "Do you have the owner's info?")
					} else if row.responseKey?.range(of: "haveInfo") != nil {
						cell.cellLabel.text = NSLocalizedString("otherpeople.doyouhavepersoninfo", comment: "Do you have this person's info?")
					}
				} else if row.responseKey?.range(of: ".injured") != nil {
					cell.cellSegmentControl.selectedIndex = showInjuryRows ? 0 : 1
				}
				
				// Fill in existing value, if any
				if let tempPerson = tempPerson, let responseKey = row.responseKey, let existingValue = tempPerson.valueFor(responseKey: responseKey) as? String {
					switch existingValue {
					case Injured.yes.rawValue:
						cell.cellSegmentControl.selectedIndex = 0
					case Injured.no.rawValue:
						cell.cellSegmentControl.selectedIndex = 1
					case Injured.unsure.rawValue:
						cell.cellSegmentControl.selectedIndex = 2
					default:
						break
					}
				}
				cell.cellSegmentControl.isEnabled = !personIsFromQuestionnaire
				return cell
			}
			
		case .textBox:
			
			// Injury description
			if row.responseKey?.range(of:".injuryDescription") != nil {
				if let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.identifier, for: indexPath) as? DetailTableViewCell {
					cell.field = row.field
					cell.delegate = self
					
					// Fill in existing value, if any
					if let tempPerson = tempPerson {
						if let details = tempPerson.injuryDetails, !details.isEmpty {
							cell.textView.text = details
							cell.textView.textColor = UIColor.black
						} else {
							cell.textView.text = row.field?.label
							cell.textView.textColor = UIColor.lightGray
						}
						return cell
					}
				}
			} else {

				// Text field
				if let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.identifier, for: indexPath) as? InfoTableViewCell {
					cell.row = row
					cell.index = indexPath.row
					cell.delegate = self

					// Fill in existing value, if any
					if let tempPerson = tempPerson, let responseKey = row.responseKey, let existingValue = tempPerson.valueFor(responseKey: responseKey) as? String {
						cell.textField.text = existingValue
					} else {
						cell.textField.text = rows[indexPath.row].value
					}
					cell.textField.isEnabled = !personIsFromQuestionnaire
					cell.textField.isEnabled = row.responseKey?.range(of: "state") == nil && row.responseKey?.range(of: "country") == nil
					cell.isPhoneNumberField = row.responseKey?.lowercased().range(of: "phonenumber") != nil
					return cell
				}
			}
			
		// Insurance date
		case .datePicker:
			if let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerCell.identifier, for: indexPath) as? DatePickerCell {
				cell.datePicker.datePickerMode = .date
				cell.row = row
				cell.field = row.field
				cell.datePickerDelegate = self
				if let placeholder = row.field?.placeHolder {
					cell.titleLabel.attributedText = Helper.requiredAttributedText(text: placeholder)
				}
				cell.datePicker.minimumDate = Date.distantPast
				cell.datePicker.maximumDate = Date.distantFuture
				if let tempPerson = tempPerson, let responseKey = row.responseKey, let existingValue = tempPerson.valueFor(responseKey: responseKey) {
					print(existingValue)
					if let date = existingValue as? Date {
						cell.datePicker.date = date
						cell.getDisplayDate(forDate: date)
					}
				}
				cell.datePicker.isEnabled = !personIsFromQuestionnaire
				return cell
			}
			
		// Photo cell
		case .photoCell:
            // TODO: Why don't we have an FNOLImage available here?!
			if let cell = tableView.dequeueReusableCell(withIdentifier: PeoplePhotoCell.identifier, for: indexPath) as? PeoplePhotoCell {
				if row.responseKey == PersonPhotoType.license.rawValue {
					cell.picture = personalInformationImage
					cell.leftLabel.text = NSLocalizedString("driverinfo.license", comment: "Driver's driving license / ID")
				} else if row.responseKey == PersonPhotoType.insurance.rawValue {
					cell.picture = insuranceVerificationImage
					cell.leftLabel.text = NSLocalizedString("driverinfo.insurance", comment: "Driver's insurance card")
				}
				if let picture = cell.picture {
                    // TODO: This should be calculated
					cell.sizeLabel.text = "3 MB"
				} else {
					cell.sizeLabel.text = ""
				}
				return cell
			}
			
		case .pickList:
			if row.responseKey?.range(of: "injuryType") != nil {

				// Injury type
				let cell = tableView.dequeueReusableCell(withIdentifier: DisclosureCell.identifier, for: indexPath) as! DisclosureCell
				cell.titleLabel.text = row.field?.label
				cell.delegate = self

				// Fill in existing value, if any
				if let tempPerson = tempPerson, let responseKey = row.responseKey, let existingValue = tempPerson.valueFor(responseKey: responseKey) as? String {
					cell.valueField.text = existingValue
				}
				return cell
			} else if let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedControlTableViewCell.identifier, for: indexPath) as? SegmentedControlTableViewCell {
				
				// Injured or Transported From Site
				cell.field = row.field
				cell.row = row
				if row.field?.responseKey?.range(of: "transportedFromScene") != nil {
					cell.cellLabel.text = NSLocalizedString("claims.transportedfromthescene", comment: "Transported from the scene")
				} else if row.field?.responseKey?.range(of: "injured") != nil {
					cell.cellLabel.attributedText = Helper.requiredAttributedText(text: NSLocalizedString("driverinfo.injured", comment: "Injured?"))
				} else if row.field?.responseKey?.range(of: "isThisPersonWitness") != nil {
					cell.cellLabel.text = NSLocalizedString("otherpeople.witnessonly", comment: "Is this person a witness only?")
				}
				cell.delegate = self

				// Fill in existing value, if any
				if let tempPerson = tempPerson, let responseKey = row.responseKey, let existingValue = tempPerson.valueFor(responseKey: responseKey) as? String {
					if responseKey.range(of: "injured") != nil {
						switch existingValue {
						case Injured.yes.rawValue:
							cell.cellSegmentControl.selectedIndex = 0
						case Injured.no.rawValue:
							cell.cellSegmentControl.selectedIndex = 1
						case Injured.unsure.rawValue:
							cell.cellSegmentControl.selectedIndex = 2
						default:
							break
						}
					} else if responseKey.range(of: "transportedFromScene") != nil {
						switch existingValue {
						case TransportedFromScene.yes.rawValue:
							cell.cellSegmentControl.selectedIndex = 0
						case TransportedFromScene.no.rawValue:
							cell.cellSegmentControl.selectedIndex = 1
						case TransportedFromScene.dontKnow.rawValue:
							cell.cellSegmentControl.selectedIndex = 2
						default:
							break
						}
					} else if responseKey.range(of: "isThisPersonWitness") != nil {
						switch existingValue {
						case IsWitness.yes.rawValue:
							cell.cellSegmentControl.selectedIndex = 0
						case IsWitness.no.rawValue:
							cell.cellSegmentControl.selectedIndex = 1
						default:
							cell.cellSegmentControl.selectedIndex = 1
						}
					} 
				}
				return cell
			}
		default:()
		}
		return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let row = rows[indexPath.row]
		switch row.type {
		case .pictureType: return defaultHeaderHeight
		case .textBox:
			if row.field?.responseKey?.range(of: "injuryDescription") != nil {
				return defaultDetailsRowHeight
			}
			return defaultRowHeight
		case .toggleType: return UITableViewAutomaticDimension
		case .additionalDetails: return defaultDetailsRowHeight
		case .datePicker:
			if row.responseKey != nil {
				return effectiveDatesStartCellExpanded ? datePickerRowHeightExpanded : datePickerRowHeight
			} else {
				return effectiveDatesEndCellExpanded ? datePickerRowHeightExpanded : datePickerRowHeight
			}
		case .photoCell: return photoCellRowHeight
		case .pickList:
			if row.responseKey?.range(of: "injuryType") != nil {
				return defaultRowHeight
			}
			return UITableViewAutomaticDimension
		case .segmentedControlCell:
			return tempPerson?.injured == Injured.yes.rawValue ? 0.0 : UITableViewAutomaticDimension
		default: return 0.0
		}
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableFooterView.identifier) as! TableFooterView
		footerCell.delegate = self
		footerCell.firstButtonText = NSLocalizedString("alert.cancel", comment: "Cancel")
		if isOwner {
			footerCell.nextButtonText = NSLocalizedString("driverinfo.addowner", comment: "Add owner")
		} else {
			switch personInfoType {
			case .driver:
				footerCell.nextButtonText = NSLocalizedString("driverinfo.adddriver", comment: "Add driver")
			case .passenger:
				footerCell.nextButtonText = NSLocalizedString("driverinfo.addpassenger", comment: "Add passenger")
			case .other:
				footerCell.nextButtonText = NSLocalizedString("driverinfo.addotherperson", comment: "Add other person")
			case .owner: // Should never happen
				break
			}
		}
		footerCell.nextButton.isEnabled = validate()
		if let name = footerSaveButtonName {
			footerCell.nextButton.setTitle(name, for: .normal)
		}
		self.footerCell = footerCell
		return footerCell
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return defaultFooterHeight
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = UIColor.clear
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = rows[indexPath.row]

		// State and country pickers
		if let suffix = row.responseKey?.components(separatedBy: ".").last {
			switch suffix {
			case "state":
				self.performSegue(withIdentifier: "showStatesVC", sender: nil)
				return
			case "country":
				self.performSegue(withIdentifier: "showCountryVC", sender: nil)
				return
			default:
				break
			}
		}

		// This is not a state or country row
		switch row.type {
		case .pictureType: do {
			if !hidePersonalInfoCells {
				if row.responseKey?.range(of: "driver.picture") != nil ||
					row.responseKey == "myVehicle.passengers[x].picture" ||
					row.responseKey == "people.contact[x].picture" {
					currentPhotoCellType = .license
				} else if row.responseKey?.range(of:"insurance.picture") != nil {
					currentPhotoCellType = .insurance
				}
				didTapOnTakePicture()
			}
		}
		case .datePicker:
			_ = tableView.cellForRow(at: indexPath) as? DatePickerCell
			if row.responseKey != nil {
				effectiveDatesStartCellExpanded = effectiveDatesStartCellExpanded ? false : true
			} else {
				effectiveDatesEndCellExpanded = effectiveDatesEndCellExpanded ? false : true
			}
			tableView.reloadData()
		case .pickList:
			if row.field?.responseKey?.range(of: "transportedFromScene") == nil && row.field?.responseKey?.range(of: "injured") == nil {
				self.performSegue(withIdentifier: "showPickerVC", sender: row.field)
			}
		default:()
		}
	}
	
}
