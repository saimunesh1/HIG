//
//  DriverInfoVC.swift
//  The General
//
//  Created by Trevor Alyn on 10/31/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol DriverInfoDelegate {
	// TODO: Do we need this to send the values back to the previous VC?
}

class DriverInfoVC: PhotoPickViewController, UITextFieldDelegate {

	@IBOutlet weak var tableView: UITableView!
	
	private let datePickerRowHeight: CGFloat = 80.0
	private let datePickerRowHeightExpanded: CGFloat = 250.0
	private let defaultFooterheight: CGFloat = 90.0
	private let defaultRowheight: CGFloat = 55.0
	private let headerRowHeight: CGFloat = 90.0
	private let keyBoardHeight: CGFloat = 180.0
	private let photoCellRowHeight: CGFloat = 175.0
	private var currentPhotoCellType: PhotoCellType?
	private var dateCellExpanded: Bool = false
	private var insuranceVerificationImage: UIImage?
	private var personalInformationImage: UIImage?
	private var personDetailsAnswers: NSMutableDictionary = [:]
	private var subFields: [Field]?

	public var delegate: DriverInfoDelegate?
	public var currentField: Field? {
		didSet {
			subFields = currentField?.subFieldsArray
		}
	}
	
	private enum PhotoCellType: String {
		case personalInformation
		case insuranceInformation
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setBackImage()
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender: )), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender: )), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		// Not sure if this is the right way to do this -- doesn't seem to work
		personalInformationImage = FNOLClaimsManager.fnolAnswerDictionary.value(forKey: "personDetails.personalInformationPhoto") as? UIImage
		insuranceVerificationImage = FNOLClaimsManager.fnolAnswerDictionary.value(forKey: "personDetails.insuranceVerificationPhoto") as? UIImage
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupTableView()
		self.title = NSLocalizedString("driverinfo", comment: "Driver info")
	}
	
	func setupTableView() {
		registerNibs()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableViewAutomaticDimension
	}
	
	static func instantiate() -> DriverInfoVC {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! DriverInfoVC
		return vc
	}
	
	@objc func keyboardWillShow(sender: NSNotification) {
		tableView.contentInset.bottom = -keyBoardHeight
	}
	
	@objc func keyboardWillHide(sender: NSNotification) {
		tableView.contentInset.bottom = 0
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if string == "\n" {
			textField.resignFirstResponder()
			return false
		}
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func registerNibs() {
		tableView.register(PictureCameraTableViewCell.nib, forCellReuseIdentifier: PictureCameraTableViewCell.identifier)
		tableView.register(InfoTableViewCell.nib, forCellReuseIdentifier: InfoTableViewCell.identifier)
		tableView.register(DatePickerTableViewCell.nib, forCellReuseIdentifier: DatePickerTableViewCell.identifier)
        tableView.register(HeaderTableViewCell.nib, forHeaderFooterViewReuseIdentifier: HeaderTableViewCell.identifier)
        tableView.register(FooterTableViewCell.nib, forHeaderFooterViewReuseIdentifier: FooterTableViewCell.identifier)
	}
	
	@objc override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		dismiss(animated: true, completion: nil)
		if let photoChosen = currentPhotoCellType {
			var image: UIImage?
			if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
				image = editedImage
			} else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
				image = originalImage
			}
			if let pickedImage = image {
				let photo = AccidentPicture(photoID: "Photo\(arc4random_uniform(3) + 1)", pImage: pickedImage)
				
				if photoChosen == .personalInformation {
					personalInformationImage = pickedImage

					// Not sure if this is the right way to do this
					FNOLClaimsManager.fnolAnswerDictionary["personDetails.personalInformationPhoto"] = photo
					
				} else if photoChosen == .insuranceInformation {
					insuranceVerificationImage = pickedImage

					// Not sure if this is the right way to do this
					FNOLClaimsManager.fnolAnswerDictionary["personDetails.insuranceVerificationPhoto"] = photo
				}
				addPhotoCell(type: photoChosen)
			}
		}
	}
	
	private func addPhotoCell(type: PhotoCellType) {
		let existingSubfield = subFields!.filter { $0.responseKey == type.rawValue }
		if existingSubfield.count < 1 {
			
			var insuranceRowIndex = -1
			for (index, subField) in subFields!.enumerated() {
				if subField.responseKey == "myVehicle.driver.insurance.picture" {
					insuranceRowIndex = index
				}
			}
			
			var responseKey: String?
			var insertLocation: Int?
			if type == .personalInformation {
				responseKey = PhotoCellType.personalInformation.rawValue
				insertLocation = insuranceRowIndex
			} else if type == .insuranceInformation {
				responseKey = PhotoCellType.insuranceInformation.rawValue
				insertLocation = subFields!.count
			}
			
			if let location = insertLocation {
                // TODO: Convert this to use MO
//                let newSubField = Field(label: nil, title: nil, type: .photoCell, defaultValue: nil, placeHolder: nil, responseKey: responseKey, required: nil, onlyDisplay: nil, rules: nil, showSubFieldsInNewPage: nil, showValuesInNewPage: nil, order: nil, validValues: nil, validations: nil, subFields: nil)
//                subFields!.insert(newSubField, at: location)
				tableView.reloadData()
			}
		}
	}

}

extension DriverInfoVC { // Photos
	
	func didTapOnTakePicture() {
		let alert: UIAlertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
		let messageFont = [NSAttributedStringKey.font: UIFont.boldTitle]
		let messageAttrString = NSMutableAttributedString(string: NSLocalizedString("alert.accident.title", comment: ""), attributes: messageFont)
		alert.setValue(messageAttrString, forKey: "attributedMessage")
		let cameraAction = UIAlertAction(title: NSLocalizedString("alert.accident.camera", comment: ""), style: UIAlertActionStyle.default) {
			UIAlertAction in self.cameraAllowsAccessToApplicationCheck()
		}
		let gallaryAction = UIAlertAction(title: NSLocalizedString("alert.accident.gallery", comment: ""), style: UIAlertActionStyle.default) {
			UIAlertAction in self.photoLibraryAvailabilityCheck()
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

extension DriverInfoVC: FooterDelegate {
	
	func didTouchonSaveExit() {
		navigationController?.popViewController(animated: true)
	}
	
	func didTouchonNextVehicles() { // Add driver
		saveDriverInfo()
		navigationController?.popViewController(animated: true)
	}
	
	private func saveDriverInfo() {
		
		// Not sure if this is the right way to do this...
		if let personalPhoto = personalInformationImage {
			FNOLClaimsManager.fnolAnswerDictionary["personDetails.personalInformationPhoto"] = personalPhoto
			addPhotoCell(type: .personalInformation)
		}
		if let insurancePhoto = insuranceVerificationImage {
			FNOLClaimsManager.fnolAnswerDictionary["personDetails.insuranceVerificationPhoto"] = insurancePhoto
			addPhotoCell(type: .insuranceInformation)
		}
	}
	
}

extension DriverInfoVC: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let subFieldArray = self.subFields {
			return subFieldArray.count
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let subFieldArray = self.subFields {
			let subField = subFieldArray[indexPath.row]
			guard let type = subField.typeEnum else {
				return UITableViewCell()
			}
			switch type {
			case .pictureType:
				if let cell = tableView.dequeueReusableCell(withIdentifier: PictureCameraTableViewCell.identifier, for: indexPath) as? PictureCameraTableViewCell {
					cell.field = subField
					if indexPath.row == 0 {
						cell.titleLabel.text = NSLocalizedString("driverinfo.personalinformation", comment: "Personal information")
					}
					return cell
				}
			case .textBox:
				if let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.identifier, for: indexPath) as? InfoTableViewCell {
					cell.item = subField
					cell.textField.delegate = self
					cell.selectionStyle = .none
					return cell
				}
			case .datePicker:
				if let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerTableViewCell.identifier, for: indexPath) as? DatePickerTableViewCell {
					cell.datePicker.datePickerMode = .date
					cell.item = subField
					if let placeHolder = subField.placeHolder {
						cell.titleLabel.attributedText = setAttributedtext(text: placeHolder)
					}
					cell.setminMaxDate()
					return cell
				}
			case .photoCell:
				if let cell = tableView.dequeueReusableCell(withIdentifier: PeoplePhotoTableViewCell.identifier, for: indexPath) as? PeoplePhotoTableViewCell {
					if subField.responseKey == PhotoCellType.personalInformation.rawValue {
						cell.picture = personalInformationImage
						cell.leftLabel.text = NSLocalizedString("driverinfo.license", comment: "Driver's driving license / ID")
					} else if subField.responseKey == PhotoCellType.insuranceInformation.rawValue {
						cell.picture = insuranceVerificationImage
						cell.leftLabel.text = NSLocalizedString("driverinfo.insurance", comment: "Driver's insurance card")
					}
					if let picture = cell.picture {
						// The following code is also in ImageCell
						let imgData: NSData = NSData(data: UIImageJPEGRepresentation((picture), 1)!)
						let imageSize: Int = imgData.length
						_ = Double(imageSize) / 1024.0
						cell.sizeLabel.text = "3 MB"//String(val/1024)
					} else {
						cell.sizeLabel.text = ""
					}
					return cell
				}
			default:()
			}
		}
		return UITableViewCell()
	}
	
	func setAttributedtext(text: String) -> NSMutableAttributedString {
		let dynamitext  = text + " *"
		let attributedString = NSMutableAttributedString(string: dynamitext)
		attributedString.setColorForText("*", with: .tgGreen)
		return attributedString
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if let subFieldArray = self.subFields {
			let subField = subFieldArray[indexPath.row]
			guard let type = subField.typeEnum else {
				return 0.0
			}
			switch type {
			case .pictureType: return headerRowHeight
			case .textBox: return defaultRowheight
			case .datePicker: return dateCellExpanded ? datePickerRowHeightExpanded : datePickerRowHeight
			case .photoCell: return photoCellRowHeight
			default: return 0.0
			}
		}
		return 0.0
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: FooterTableViewCell.identifier) as! FooterTableViewCell
		footerCell.delegate = self
		footerCell.nextButtonText = "Add Driver"
		return footerCell
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return defaultFooterheight
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = UIColor.clear
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let subFieldArray = self.subFields {
			let subField = subFieldArray[indexPath.row]
			guard let type = subField.typeEnum else {
				return
			}
			switch type {
			case .pictureType: do {
				if subField.responseKey == "myVehicle.driver.picture" {
					currentPhotoCellType = .personalInformation
				} else if subField.responseKey == "myVehicle.driver.insurance.picture" {
					currentPhotoCellType = .insuranceInformation
				}
				didTapOnTakePicture()
			}
				break
			case .textBox:
				break
			case .datePicker:
				_ = tableView.cellForRow(at: indexPath) as? DatePickerTableViewCell
				dateCellExpanded =  dateCellExpanded ? false : true
				tableView.reloadData()
			default:()
			}
		}
	}
	
}
