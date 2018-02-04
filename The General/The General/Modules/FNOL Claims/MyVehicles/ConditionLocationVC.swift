//
//  ConditionLocationTableVC.swift
//  The General
//
//  Created by Michael Moore on 10/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import CoreLocation

class ConditionLocationVC: UITableViewController {
    
    var viewModel: Questionnaire!
    var currentPage: Page?
    var currentField: Field?
    var values: [Value]?
    var fields: [Field] = [] {
        didSet {
			// Preload switch values
			for field in fields {
				if field.responseKey?.range(of: "canVehicleSafelyDiven") != nil && getValueForKey(key: field.responseKey!)!.isEmpty {
					updateValueForKey(key: field.responseKey!, value: "yes")
				} else if field.responseKey?.range(of: "canWeMoveYourVehicle") != nil && getValueForKey(key: field.responseKey!)!.isEmpty {
					updateValueForKey(key: field.responseKey!, value: "no")
				}
			}
            tableView.reloadData()
        }
    }
    
    var tempAddress = FNOLAddressTemporary()
    
    var mainFieldType = ""
    
    var conditionLocationAnswers: NSMutableDictionary = [:]
    
    private var extraCellsExpanded = false {
        didSet {
            tableView.reloadData()
        }
    }
    private var dateCellExpanded = false
    private var datePickerCellExpanded = false
    
    var addressCell: AddressCell?
    var pickerValueCell: DisclosureCell?
    
    var togglePickerResponseKey = "myVehicle.vehicleConditionAndLocation.canVehicleSafelyDriven"
    var toggleDateResponseKey = "myVehicle.vehicleConditionAndLocation.canWeMoveYourVehicle"
    var dateFieldResponseKey = "myVehicle.vehicleConditionAndLocation.whenCanMove"
    
    private var separatorInset: CGFloat = 12.0
    private let defaultRowheight: CGFloat = 77.0
    private let locationSelectionRowHeight: CGFloat = 186.0
    private let pickerRowHeight: CGFloat = 250.0
    private let defaultHeaderheight: CGFloat = 90.0
    private let defaultFooterheight: CGFloat = 90.0
    private let textViewCellHeight: CGFloat = 70.0
    private let addressRowHeight: CGFloat = 110.0
    private var footerHeight: CGFloat = 120.0
    private let keyBoardHeight: CGFloat = 180.0
    
    var deviceLatitude: Double = 0.0
    var deviceLongtitude: Double = 0.0
    var isLocationsAccessed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender: )), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender: )), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
        self.prepareCondtionLocationDetails()
        
        registerNibs()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func registerNibs() {
        tableView.register(DisclosureCell.nib, forCellReuseIdentifier: DisclosureCell.identifier)
        tableView.register(ThreeLocationCell.nib, forCellReuseIdentifier: ThreeLocationCell.identifier)
        tableView.register(AddressCell.nib, forCellReuseIdentifier: AddressCell.identifier)
        tableView.register(LocationDatePickerTableViewCell.nib, forCellReuseIdentifier: LocationDatePickerTableViewCell.identifier)
        tableView.register(TextBoxTableViewCell.nib, forCellReuseIdentifier: TextBoxTableViewCell.identifier)
        tableView.register(TableHeaderView.nib, forCellReuseIdentifier: TableHeaderView.identifier)
        tableView.register(SegmentedControlTableViewCell.nib, forCellReuseIdentifier: SegmentedControlTableViewCell.identifier)
        tableView.register(DoneFooterTableViewCell.nib, forHeaderFooterViewReuseIdentifier: DoneFooterTableViewCell.identifier)
        
        tableView.separatorInset.left = separatorInset
        tableView.separatorInset.right = separatorInset
        tableView.separatorColor = .tgGray
    }
    
    func prepareCondtionLocationDetails() {
        guard let page: Page = viewModel.getPageForId(id: "my_vehicle_details") else {
            return
        }
        currentPage = page
        guard let pageID = currentPage?.pageId, let sectionList = viewModel.getSectionList(pageID: pageID), let currentSection = sectionList.first else { return }
        
        currentField = currentSection.fieldsArray?.first { $0.typeEnum == .vehicleConditionLocation }
        title = currentField?.title
        guard let currentField = currentField, let subfields = currentField.subFieldsArray else { return }
        
        fields = subfields
        mainFieldType = currentField.type ?? ""
        
        if let val = getValueForKey(key: togglePickerResponseKey) {
             conditionLocationAnswers[togglePickerResponseKey] = val
        }
        if let extraCellsExpandedValue = conditionLocationAnswers[togglePickerResponseKey] as? String {
            extraCellsExpanded = extraCellsExpandedValue != "yes"
        }
        if let val = getValueForKey(key: toggleDateResponseKey) {
            conditionLocationAnswers[toggleDateResponseKey] = val
        }
        if let dateCellsExpandedValue = conditionLocationAnswers[toggleDateResponseKey] as? String {
            if dateCellsExpandedValue == "yes" {
                if let field = fields.first(where: { fieldValue in
                    fieldValue.responseKey == toggleDateResponseKey
                }) {
                    if let subfield = field.subFieldsArray?.first {
                        if let index = fields.index(where: { field in
                            field.responseKey == toggleDateResponseKey
                        }) {
                            fields.insert(subfield, at: index + 1)
                            datePickerCellExpanded = true
                        }
                    }
                }
            }
        }
		for field in fields {
			if let responseKey = field.responseKey {
				if let value = getValueForKey(key: responseKey) {
					conditionLocationAnswers[responseKey] = value
				}
			}
		}
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
            guard let address = self.addressCell?.accidentLocationAddress else {
                return
            }
            vc.currentAddress = address
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func instantiate() -> ConditionLocationVC {
        let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! ConditionLocationVC
        return vc
    }
    
    @IBAction func goBack(segue: UIStoryboardSegue) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        tableView.contentInset.bottom = keyBoardHeight
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        tableView.contentInset.bottom = 0
    }

}

extension ConditionLocationVC: PickerDelegate, AddressLocationDelegate, ThreeLocationCellDelegate {

	func didTouchOnLocation() {
		didTouchOnMyLocation()
	}
	
	func didAccidentPhotosPicked(imageArray: [FNOLImage]) {}
	
	func didTouchOnAccidentLocation() {
		guard let cell = self.addressCell else { return }
		AddressInfo.fetchSavedAddress { (tempAddress) in
			cell.accidentLocationAddress = tempAddress
			cell.addressValueLabel.text = tempAddress.asString()
			cell.accidentLocationAddress?.storeVehicleConditionLocationAddress()
			self.tableView.reloadData()
		}
	}
    
    func didTouchOnMyLocation() {
		ApplicationContext.shared.locationManager.checkLocationAccess(success: {
			self.getAddressFromLocation()
		}, failure: {
			self.showLocationDisabledpopUp()
		})
	}

	private func getAddressFromLocation() {
        guard let cell = self.addressCell else { return }
		ApplicationContext.shared.locationManager.getAddressFromLocation { (address) in
			cell.accidentLocationAddress = address
			cell.accidentLocationAddress?.storeVehicleConditionLocationAddress()
			cell.addressValueLabel.text = address?.asString()
			self.tableView.reloadData()
		}
    }
    
    func didTouchOnHome() {
        let obj =  self.viewModel?.addressInfosArray?.filter{$0.type == "MyHome"}
        guard let cell = self.addressCell, let value = obj?.first else { return }
        var tempAddress = FNOLAddressTemporary()
        cell.accidentLocationAddress = tempAddress.updateFromQuestionnaire(temp: value)
        cell.addressValueLabel.text = tempAddress.asString()
        cell.accidentLocationAddress?.storeVehicleConditionLocationAddress()
        self.tableView.reloadData()
    }
    
    func onTouchOnSave(addressInfo: FNOLAddressTemporary) {
        guard let cell = self.addressCell else { return }
        cell.accidentLocationAddress = addressInfo
        cell.accidentLocationAddress?.storeVehicleConditionLocationAddress()
        cell.addressValueLabel.text = addressInfo.asString()
    }
    
	func didPickSubField(value: String, displayValue: String, responseKey: String) {
        pickerValueCell?.field?.defaultValue  = value
        pickerValueCell?.valueField.text = displayValue
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


extension ConditionLocationVC {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return extraCellsExpanded ? fields.count : 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let field = fields[indexPath.row]
        
        guard let type = field.typeEnum else {
            return UITableViewCell()
        }
        switch  type {
        case .pickList:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedControlTableViewCell.identifier, for: indexPath) as? SegmentedControlTableViewCell {
                cell.field = field
                cell.delegate = self
                if let responseKey = field.responseKey, let value = conditionLocationAnswers[responseKey] as? String {
                    if let index = cell.responseCodes?.index(of: value) {
                        cell.cellSegmentControl.selectedIndex = index
					}
                }
                return  cell
            }
        case .vehicleLocationPickList:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ThreeLocationCell.identifier, for: indexPath) as? ThreeLocationCell {
                cell.selectionStyle = .none
                cell.delegate = self
                cell.field = field
                cell.titleLabel.text = field.label
                return cell
            }
        case .datePicker:
            if let cell = tableView.dequeueReusableCell(withIdentifier: LocationDatePickerTableViewCell.identifier, for: indexPath) as? LocationDatePickerTableViewCell {
                cell.datePicker.datePickerMode = .date
                cell.field = field
				cell.fetchSavedvalues()
                if field.required == true {
                    cell.titleLabel.attributedText = Helper.requiredAttributedText(text:field.label!)
                } else {
                    cell.titleLabel.text = field.label
                }
                cell.selectionStyle = .none
                cell.valueField.placeholder = field.placeHolder
				cell.datePicker.minimumDate = Date()
                cell.datePicker.maximumDate = nil
                cell.delegate = self
                if let responseKey = field.responseKey, let value = conditionLocationAnswers[responseKey] {
                    cell.valueField.text = value as? String
                }
                return cell
            }
        case .addressType:
            if let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.identifier, for: indexPath) as? AddressCell {
                cell.field = field
                addressCell = cell
                cell.selectionStyle = .none
                
                if field.required {
                    cell.addressLabel.attributedText = Helper.requiredAttributedText(text:field.label!)
                } else {
                    cell.addressLabel.text = field.label
                }
                AddressInfo.fetchVehicleConditionAddress{(address) in
                    cell.accidentLocationAddress = address
                    cell.getSavedConditionLocationString()
                }
                addressCell = cell
                return cell
            }
        case .textBox:
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextBoxTableViewCell.identifier, for: indexPath) as? TextBoxTableViewCell {
                cell.item = field
                cell.textView.delegate = self
                cell.selectionStyle = .none
                if let responseKey = field.responseKey, let value = conditionLocationAnswers[responseKey] as? String {
                    cell.textView.text = value
                }
                cell.textView.placeholder = field.placeHolder
				cell.textView.resizePlaceholder()
                return cell
            }
        default:()
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let field = fields[indexPath.row]
        
        guard let type = field.typeEnum else {
            return 0.0
        }
        switch type {
        case .pickList, .pictureType : return defaultRowheight
        case .datePicker: return dateCellExpanded ? pickerRowHeight : defaultRowheight
        case .vehicleLocationPickList: return locationSelectionRowHeight
        case .quickPick: return locationSelectionRowHeight
        case .addressType: return addressRowHeight
        case .textBox, .additionalDetails : return textViewCellHeight
        default: return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let field = fields[indexPath.row]
        
        guard let type = field.typeEnum else {
            return
        }
        switch  type {
        case .pickList:do {
            guard let cell = tableView.cellForRow(at: indexPath) as? DisclosureCell else {
                return
            }
            self.pickerValueCell = cell
            self.performSegue(withIdentifier: "showPickerVC", sender: field)
            }
        case .addressType:do {
			let addressField = currentField!.subFieldsArray!.filter({ $0.label == "Address" }).first
            self.performSegue(withIdentifier: "showAddressFormVC", sender: addressField)
            }
        case .datePicker:do {
            let cell = tableView.cellForRow(at: indexPath) as? LocationDatePickerTableViewCell
            dateCellExpanded =  dateCellExpanded ? false : true
            cell?.setCurrentDate()
            if let key = field.responseKey, let cell = cell {
                
                let formatter = DateFormatter()
                formatter.dateStyle = DateFormatter.Style.long
                let dateString = formatter.string(from: cell.datePicker.date)
                conditionLocationAnswers[key] = dateString
            }
            tableView.reloadData()
            }
        default:()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 1 ? footerHeight : 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: DoneFooterTableViewCell.identifier) as! DoneFooterTableViewCell
        footerCell.delegate = self
        return footerCell
    }
    
    func updateValueForKey(key: String, value: String?) {
        ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value ?? "", displayValue: nil, forResponseKey: key)
    }
    
    func getValueForKey(key: String) -> String? {
        guard let value = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: key) else {
            return ""
        }
        return value
    }
}

extension ConditionLocationVC: DamageDetailsFooterDelegate {
    
    func touchOnDone() {
        for cell in tableView.visibleCells {
            switch cell {
            case is TextBoxTableViewCell:
                if let customCell = cell as? TextBoxTableViewCell {
                    if let field = customCell.item, let key = field.responseKey {
                        conditionLocationAnswers[key] = customCell.textView.text
                    }
                }
            case is AddressCell:()
                
            default:
                continue
            }
        }
        //Update all user selections to active cliam
        for (key, element) in self.conditionLocationAnswers {
            self.updateValueForKey(key: (key as? String)!, value: element as? String)
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension ConditionLocationVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}

extension ConditionLocationVC: LocationDatePickerCellDelegate {
    func datePicked(date: String, field: Field?) {
        if let key = field?.responseKey {
            conditionLocationAnswers[key] = date
        }
    }
}

extension ConditionLocationVC: SegmentedControlTableViewCellDelegate {
    func didSwitch(index: Int, row: Row?) {
    }
    
    func segmentValueChanged(field: Field, value: String) {
        
        switch field.responseKey ?? "" {
        case togglePickerResponseKey:
            
            extraCellsExpanded = value != "yes"
            
            if value == "yes" {
                conditionLocationAnswers[toggleDateResponseKey] = ""
                conditionLocationAnswers = [:]
            }
            
            conditionLocationAnswers[togglePickerResponseKey] = value
            
        case toggleDateResponseKey:
            conditionLocationAnswers[toggleDateResponseKey] = value
            
            if value == "yes" {
                if !datePickerCellExpanded {
                    if let subfield = field.subFieldsArray?.first {
                        if let index = fields.index(where: { field in
                            field.responseKey == toggleDateResponseKey
                        }) {
                            fields.insert(subfield, at: index + 1)
                            datePickerCellExpanded = true
                        }
                    }
                }
            } else {
                if datePickerCellExpanded {
                    if let index = fields.index(where: { field in
                        field.responseKey == dateFieldResponseKey
                    }) {
                        fields.remove(at: index)
                        datePickerCellExpanded = false
                        if let subfield = field.subFieldsArray?.first, let key = subfield.responseKey {
                            conditionLocationAnswers[key] = ""
                        }
                    }
                }
            }
        default:
            return
        }
    }
}

extension ConditionLocationVC {
	
    func showLocationDisabledpopUp() {
        let alertController = UIAlertController(title: "", message: NSLocalizedString("alert.location.message", comment: ""), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString( "alert.cancel", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: NSLocalizedString("alert.settings", comment: ""), style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ConditionLocationVC: UITextViewDelegate {
    
    
    func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = textView.text.count > 0
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewShouldReturn(_ textView: UITextField) -> Bool {
        textView.resignFirstResponder()
        return true
    }
}
