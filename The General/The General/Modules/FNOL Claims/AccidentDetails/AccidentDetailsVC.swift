//
//  AccidentDetailsVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import CoreLocation

class AccidentDetailsVC: PhotoPickViewController, UITextViewDelegate {
    
	@IBOutlet weak var tableView: UITableView!

	var addressCell: AddressCell?
	var pickerValueCell: DisclosureCell?
	var pictureCell: PhotoCell?
	var viewModel: Questionnaire?
    var sectionsList: [Section] = []
    var details = FNOLAccidentDetailsTemporary()
	
	private var accidentDate: Date?
	private var accidentTimeCell: DatePickerCell?
    private var dateCellExpanded: Bool = false
    private var timeCellExpanded: Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        automaticallyAdjustsScrollViewInsets = false
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setupTableView() {
        registerNibs()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        guard let list = self.viewModel?.getSectionList(pageID: "accident_details") else { return }
        self.sectionsList = list
    }
    
    static func instantiate() -> AccidentDetailsVC {
        let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! AccidentDetailsVC
        
        return vc
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPickerVC" {
            let vc  = segue.destination as! PickerVC
            vc.delegate = self
            vc.currentField = sender as? Field
        } else if segue.identifier == "showAddressFormVC" {
            let vc = segue.destination as! AddressFormVC
            vc.delegate = self
            vc.addressFieldFromQuestionnaire = sender as? Field
            guard let currentAddress = addressCell?.accidentLocationAddress else{
                return
            }
            vc.currentAddress = currentAddress
            vc.currentAddress.storeAccidentDetailsAddress()
        } else if segue.identifier == "showAddPhotoVC" {
            let vc = segue.destination as! AddPhotoVC
            vc.currentField = sender as? Field
            vc.delegate = self
        } else if (segue.identifier == "showPhotoPreviewVC") {
            let vc = segue.destination as! PhotoPreviewVC
            vc.currentField = sender as? Field
            vc.delegate = self
        } else if segue.identifier == "showVehiclesContainerVC" {
            let vc = segue.destination as! VehiclesContainerVC
            vc.navigationItem.title = "My Vehicle"
            vc.viewModel = self.viewModel
            guard let currentAddress = addressCell?.accidentLocationAddress else {
                return
            }
            currentAddress.storeAccidentDetailsAddress()
		}
    }
	
    func registerNibs() {
        tableView.register(AddressLocationCell.nib, forCellReuseIdentifier: AddressLocationCell.identifier)
        tableView.register(AddressCell.nib, forCellReuseIdentifier: AddressCell.identifier)
        tableView.register(DatePickerCell.nib, forCellReuseIdentifier: DatePickerCell.identifier)
        tableView.register(DetailTableViewCell.nib, forCellReuseIdentifier: DetailTableViewCell.identifier)
        tableView.register(DisclosureCell.nib, forCellReuseIdentifier: DisclosureCell.identifier)
        tableView.register(PhotoCell.nib, forCellReuseIdentifier: PhotoCell.identifier)
        tableView.register(TableFooterView.nib, forHeaderFooterViewReuseIdentifier: TableFooterView.identifier)
        tableView.register(TableHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableHeaderView.identifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension AccidentDetailsVC: PickerDelegate, AddressLocationDelegate{
    
    func didAccidentPhotosPicked(imageArray: [FNOLImage]) {
        if imageArray.count > 0 {
            pictureCell?.valueField.text = imageArray.count > 1 ? "\( imageArray.count) \(NSLocalizedString("label.photos", comment: ""))" : "\( imageArray.count) \(NSLocalizedString("label.photo", comment: ""))"
        }else{
            pictureCell?.valueField.placeholder =  pictureCell?.field?.placeHolder
            pictureCell?.valueField.text = ""
        }
        
        let vcIndex = self.navigationController?.viewControllers.index(where: { (viewController) -> Bool in
            if let _ = viewController as? AccidentDetailsContainerVC {
                return true
            }
            return false
        })
        
        let destination = self.navigationController?.viewControllers[vcIndex!] as! AccidentDetailsContainerVC
        self.navigationController?.popToViewController(destination, animated: true)
    }
    
    func didTouchOnLocation() {
		ApplicationContext.shared.locationManager.checkLocationAccess(success: {
			self.getAddressFromLocation()
		}, failure: {
			self.showLocationDisabledAlert()
		})
	}
	
	private func getAddressFromLocation() {
		guard let cell = self.addressCell, CLLocationManager.locationServicesEnabled() else { return }
		ApplicationContext.shared.locationManager.getAddressFromLocation { (locationAddress) in
			cell.accidentLocationAddress = locationAddress
			cell.addressValueLabel.text = locationAddress?.asString()
			cell.accidentLocationAddress?.storeAccidentDetailsAddress()
			self.tableView.reloadData()
		}
    }
    
    func didTouchOnHome() {
        let obj =  self.viewModel?.addressInfosArray?.filter{$0.type == "MyHome"}
        guard let cell = self.addressCell,
            let value = obj?.first
            else { return }
        
        var tempAddress = FNOLAddressTemporary()
        cell.accidentLocationAddress = tempAddress.updateFromQuestionnaire(temp: value)
        cell.addressValueLabel.text = tempAddress.asString()
        cell.accidentLocationAddress?.storeAccidentDetailsAddress()
        self.tableView.reloadData()
    }
    
    func onTouchOnSave(addressInfo: FNOLAddressTemporary) {
        guard let cell = self.addressCell else { return }
        cell.accidentLocationAddress = addressInfo
        cell.addressValueLabel.text = addressInfo.asString()
        cell.accidentLocationAddress?.storeAccidentDetailsAddress()
        self.tableView.reloadData()

    }
    
	func didPickSubField(value: String, displayValue: String, responseKey: String) {
        pickerValueCell?.field?.defaultValue  = displayValue
        pickerValueCell?.valueField.text = displayValue
        pickerValueCell?.errorLabel.text = ""
        pickerValueCell?.errorLabel.isHidden = true
		pickerValueCell?.promptLabel.text = ""
		ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: displayValue, forResponseKey: responseKey)
        
        let vcIndex = self.navigationController?.viewControllers.index(where: { (viewController) -> Bool in
            if let _ = viewController as? AccidentDetailsContainerVC {
                return true
            }
            return false
        })
        
        let destination = self.navigationController?.viewControllers[vcIndex!] as! AccidentDetailsContainerVC
        self.navigationController?.popToViewController(destination, animated: true)
	}
}

extension AccidentDetailsVC: DetailTableViewCellDelegate {
    
    func didFinishEditing(value: String, cell: DetailTableViewCell) {
        if let responseKey = cell.field?.responseKey {
			ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: responseKey)
        }
    }
}

extension AccidentDetailsVC: FooterDelegate, UIValidationDelegate{
    func didTouchLeftButton() {
		showSaveQuitActionSheet()
		
        // Handles removing the top-bar when user navigates back
        if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
            supplementalNavigationController?.removeSupplementalView(topBarView, animated: false)
        }
    }
    
    func didTouchRightButton() {
        formValidator.validate(self)
    }
    
    func validationSuccessful() {
		AddressInfo.fetchSavedAddress { (address) in
			address.storeAccidentDetailsAddress()
		}
        self.performSegue(withIdentifier: "showVehiclesContainerVC", sender: self)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)]) {
        self.tableView.reloadData()
    }
}

extension AccidentDetailsVC: UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = sectionsList[section]
        return (currentSection.getFieldsForSection()?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentSection = sectionsList[indexPath.section]
        let currentField = currentSection.getFieldsForSection()![indexPath.row]
        
        guard let type = currentField.typeEnum else {
            return UITableViewCell()
        }
        switch type {
            //Accident Type and Location Picker
        case .pickList:
            if let cell = tableView.dequeueReusableCell(withIdentifier: DisclosureCell.identifier, for: indexPath) as? DisclosureCell {
                cell.field = currentField
                if cell.field?.required == true {
                    formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
                }
                if (currentField.required) {
                    cell.titleLabel.attributedText = Helper.requiredAttributedText(text:(currentField.label!))
                }else{
                    cell.titleLabel.text = currentField.label
                }
                cell.fetchSavedClaimValues()
				
				// Hardcoding this because by default, we put the placeholder in the value field,
				// which causes the field to be valid even if the user hasn't specified an accident type
				// TODO: Fix this everywhere DisclosureCell is used.
				if let field = cell.field, let responseKey = field.responseKey, let _ = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: responseKey) {
					// We have a value for this field; do nothing
				} else {
					// Show the placeholder in the prompt field
					cell.valueField.text = ""
					cell.promptLabel.text = cell.field?.placeHolder
				}
                return cell
            }
			
		// Accident Pictures
        case .pictureType:
            if let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell {
                cell.field = currentField
                if cell.field?.required == true {
                    formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
                }
                cell.checkForRequired()
                cell.fetchSavedvalues()
                return cell
            }
            
		// Current Location and Home location Quick pick
        case .quickPick:
            if let cell = tableView.dequeueReusableCell(withIdentifier: AddressLocationCell.identifier, for: indexPath) as? AddressLocationCell {
                cell.delegate = self
                cell.item = currentField
                return cell
            }
        case .addressType:
            if let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.identifier, for: indexPath) as? AddressCell {
                cell.field = currentField
                cell.checkRequired()
                AddressInfo.fetchSavedAddress(){ (address) in
                    cell.accidentLocationAddress = address
                    cell.getSavedAddressString()
                }
                addressCell = cell
                return cell
            }
        case .datePicker:
            if let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerCell.identifier, for: indexPath) as? DatePickerCell {
                cell.datePicker.datePickerMode = .date
                cell.field = currentField
                if cell.field.required == true {
                    formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
                }
                cell.checkForRequired()
                cell.fetchSavedvalues()
                cell.datePicker.maximumDate = Date()
				cell.datePickerDelegate = self
                return cell
            }
        case .timePicker:
            if let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerCell.identifier, for: indexPath) as? DatePickerCell {
                cell.field = currentField
                // Check for mandatory
                if cell.field.required == true {
                    formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
                }
                cell.datePicker.datePickerMode = .time
				cell.datePicker.maximumDate = Date()
                cell.checkForRequired()
                cell.fetchSavedvalues()
				if let accidentDate = accidentDate {
					cell.setDateForTime(date: accidentDate)
				}
				accidentTimeCell = cell
                return cell
            }
        case .textBox:
            if let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.identifier, for: indexPath) as? DetailTableViewCell {
                cell.field = currentField
                cell.delegate = self
                cell.selectionStyle = .none
                cell.fetchValues()
                
                return cell
            }
        default:()
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentSection = sectionsList[indexPath.section]
        let currentField = currentSection.getFieldsForSection()![indexPath.row]
        
        guard let type = currentField.typeEnum else {
            return 0.0
        }
        switch type {
        case .pickList, .pictureType : return defaultRowHeight
        case .datePicker: return dateCellExpanded ? pickerExpandedRowHeight : datePickerRowHeight
        case .timePicker: return timeCellExpanded ? pickerExpandedRowHeight : datePickerRowHeight
        case .quickPick: return UITableViewAutomaticDimension
        case .addressType: return UITableViewAutomaticDimension
        case .textBox, .additionalDetails : return defaultDetailsRowHeight
        default: return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.identifier) as! TableHeaderView
        let currentSection = sectionsList[section]
        let title = currentSection.sectionName?.lowercased()
        cell.headerLabel?.text = title?.firstUppercased
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let  footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableFooterView.identifier) as! TableFooterView
        footerCell.delegate = self
        return section == sectionsList.count - 1 ? footerCell : nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == sectionsList.count - 1 ? defaultFooterHeight : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSection = self.sectionsList[indexPath.section]
        let currentField = currentSection.getFieldsForSection()![indexPath.row]
        guard let type = currentField.typeEnum else { return }
        switch type {
        case .pickList:
            guard let cell = tableView.cellForRow(at: indexPath) as? DisclosureCell else { return }
            self.pickerValueCell = cell
			if cell.field?.responseKey == "accidentDetails.whatHappened.type" {
				cell.promptLabel.text = ""
			}
            self.performSegue(withIdentifier: "showPickerVC", sender: currentField)
            
        case .addressType:
            self.performSegue(withIdentifier: "showAddressFormVC", sender: currentField)
            
		// For Accident Pictures
        case .pictureType:
            guard let cell = tableView.cellForRow(at: indexPath) as? PhotoCell,
                let imageList = ApplicationContext.shared.fnolClaimsManager.activeClaim?.images(forResponseKey:"accidentDetails.accidentPictures") else{
                    return
            }
            if imageList.count > 0 {
                self.performSegue(withIdentifier: "showPhotoPreviewVC", sender: currentField)
            }else{
                self.performSegue(withIdentifier: "showAddPhotoVC", sender: currentField)
            }
            self.pictureCell = cell
			
		// For Date & Time picker
        case .datePicker, .timePicker:
            guard let cell = tableView.cellForRow(at: indexPath) as? DatePickerCell else { return }
            if type == .timePicker {
                timeCellExpanded =  timeCellExpanded ? false : true
                dateCellExpanded = false
            }else{
                dateCellExpanded =  dateCellExpanded ? false : true
                timeCellExpanded = false
            }
            if cell.valueField.text?.isEmpty ?? true {
                cell.updateDate(date: Date())
            }
            // Update date when tap on cell
			cell.updateDate(date: cell.datePicker.date)

			tableView.reloadData()
			
        default:()
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            tableView.contentInset = UIEdgeInsets.zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableViewScrollToBottom(animated: true)
    }
    
    //Keyboard handling
    func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
}

extension AccidentDetailsVC: DatePickerCellDelegate {
	
	// Only called by date picker cell (not time picker cell)
	func didPickDate(date: Date, field: Field?, row: Row?) {
		accidentDate = date
		accidentTimeCell?.setDateForTime(date: date)
	}

}
