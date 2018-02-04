//
//  VehicleInfoVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/29/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(_ section: Int)
	func didTapOnTakePicture(isSelected: Bool, field: Field?)
}

class VehicleInfoVC: PhotoPickViewController {
	
	@IBOutlet var tableView: UITableView!

	static let addVehicleIdentifier = Notification.Name("vehicleAdded")

	private var dateCellExpanded: Bool = false
	private var photoType: VehicleImageType!
	private var hasVehicleInfo = false
	private var tempVehicle: FNOLVehicleTemporary!
	private var licensePlateImageAvailable: Bool = false
	private var vinImageAvailable: Bool = false
	
    var hidden: [Bool] = [true, true]
    var delegate: VehicleListFooterDelegate?
    var selectedField: Field?
    var currentSection: Section?
    var pickerList: [String] = []
    var colourPickCell: MyVehicleRowCell? = nil
    var makeCell: MyVehicleRowCell? = nil
    var modelCell: MyVehicleRowCell? = nil
    var sectionFields: [Field]?
	var licensePlateImage: UIImage?
	var vinNumberImage: UIImage?

    var isYearSelected: Bool = false
    var isMakeSelected: Bool = false
    var isModelSelected: Bool = false
    var isColourSelected: Bool = false
    
    var selectedYear: String = ""
    var selectedMake: String = ""
    var selectedModel: String = ""
    var selectedColour: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempVehicle = FNOLVehicleTemporary()
        
        tableView.register(VINNumberCell.nib, forCellReuseIdentifier: VINNumberCell.identifier)
        tableView.register(LicenseTableViewCell.nib, forCellReuseIdentifier: LicenseTableViewCell.identifier)
        tableView.register(TakePictureTableViewCell.nib, forCellReuseIdentifier: TakePictureTableViewCell.identifier)
        tableView.register(MyVehicleRowCell.nib, forCellReuseIdentifier: MyVehicleRowCell.identifier)
		tableView.register(MyVehicleEditableRowCell.nib, forCellReuseIdentifier: MyVehicleEditableRowCell.identifier)
        tableView.register(HeaderFooterViewCell.nib, forHeaderFooterViewReuseIdentifier: HeaderFooterViewCell.identifier)
        tableView.register(SegmentedControlTableViewCell.nib, forCellReuseIdentifier: SegmentedControlTableViewCell.identifier)
        tableView.register(YearPicker.nib, forCellReuseIdentifier: YearPicker.identifier)
        tableView.register(TableFooterView.nib, forHeaderFooterViewReuseIdentifier: TableFooterView.identifier)
        
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender: )), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender: )), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Workaround for showing Colour field and order of the data and VIN field
        handleDataSourceForVehicle()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleDataSourceForVehicle() {
        sectionFields = (selectedField?.subFields?.filter{($0 as! Field).typeEnum != .toggleType && ($0 as! Field).typeEnum != .vehicleYearPicker} as! [Field])
        
        let colourField: [Field] = (currentSection?.fields?.filter{($0 as! Field).typeEnum == .pickList } as! [Field])
        sectionFields?.append(colourField.first!)
        
        //TODO - workaround as we dont have VIN field in Questionaire
        guard let vinField = colourField.first else {
            return
        }
        let newVINField  = vinField.shallowCopy() as! Field
        newVINField.responseKey = "myVehicle.vehicleInfo.vin"
        newVINField.label = "VIN Number"
        newVINField.placeHolder = "VIN Number"
        newVINField.type = "vin_number"
        sectionFields?.insert(newVINField, at: 0)
        let yeardField: [Field] = (selectedField?.subFields?.filter{($0 as! Field).typeEnum == .vehicleYearPicker} as! [Field])
        sectionFields?.insert(yeardField.first!, at: 2)
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let cell = sender as? MyVehicleRowCell
		guard let type = cell?.item?.typeEnum else {
			return
		}
		if (segue.identifier == "showPickMakeModelVC") {
			let vc = segue.destination as! PickMakeModelVC
			vc.navigationItem.title = "\(cell?.item?.label ?? "")"
			vc.dataSourceArray = self.pickerList
			vc.callback = { (value) in
				self.updaterecords(cellType: type, selectedValue: value)
				ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: (cell?.item?.responseKey!)!)
				cell?.valueField.text = value
				cell?.errorLabel.text = ""
			}
		}
	}
	
	override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		let image = info[UIImagePickerControllerOriginalImage] as! UIImage
		switch photoType {
		case .licensePlate:
			licensePlateImageAvailable = true
			licensePlateImage = image
		case .vinNumber:
			vinImageAvailable = true
			vinNumberImage = image
		default:
			break
		}
		photoType = nil
		if picker.sourceType == .camera {
			UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_: didFinishSavingWithError: contextInfo: )), nil)
		}
		picker.dismiss(animated: true, completion: nil)
		tableView.reloadData()
	}
	
	@objc override func keyboardWillShow(sender: NSNotification) {
		tableView.contentInset.bottom = keyboardHeight
	}
	
	@objc override func keyboardWillHide(sender: NSNotification) {
		tableView.contentInset.bottom = 0
	}

	override func goBack(segue: UIStoryboardSegue) {
		confirmDelete {
			super.goBack(segue: segue)
		}
	}
	
	private func confirmDelete(completion: @escaping () -> Void) {
		let alert: UIAlertController = UIAlertController(title: "", message: nil, preferredStyle: .alert)
		let messageFont = [NSAttributedStringKey.font: UIFont.boldTitle]
		let messageAttrString = NSMutableAttributedString(string: NSLocalizedString("othervehicle.discard", comment: "Discard vehicle info?"), attributes: messageFont)
		alert.setValue(messageAttrString, forKey: "attributedMessage")
		let noAction = UIAlertAction(title: NSLocalizedString("alert.no", comment: "No"), style: .cancel) { UIAlertAction in
			// Do nothing
		}
		let yesAction = UIAlertAction(title: NSLocalizedString("alert.yes", comment: "Yes"), style: .default) {
			UIAlertAction in
			completion()
		}
		alert.addAction(noAction)
		alert.addAction(yesAction)
		self.present(alert, animated: true, completion: nil)
	}

}

extension VehicleInfoVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentField = sectionFields![indexPath.row]
        guard let type = currentField.typeEnum else {
            return UITableViewCell()
        }
        switch  type {
            // Vehicle VIN number
        case .vinNumber:
			if vinImageAvailable {
				if let pictureCell = tableView.dequeueReusableCell(withIdentifier: LicenseTableViewCell.identifier, for: indexPath) as? LicenseTableViewCell {
					pictureCell.item = currentField
					
					// Delete the VIN number pic
					pictureCell.deletePictureCallBack = { [weak self] (value) in
						guard let weakSelf = self else { return }
						weakSelf.vinNumberImage = nil
						weakSelf.vinImageAvailable = false
						weakSelf.tableView.reloadData()
					}
					// VIN number field
					pictureCell.textFieldCallback = { [weak self] (value) in
						guard let weakSelf = self else { return }
						weakSelf.tempVehicle?.vin =  value
						ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: currentField.responseKey!)
					}
					pictureCell.valueTextField.placeholder = NSLocalizedString("vehicleinfo.vinnumber", comment: "VIN number")
					pictureCell.itemImageView.image = self.vinNumberImage
					
					// Add VIN plate image to claim
					ApplicationContext.shared.fnolClaimsManager.activeClaim?.setImage(self.vinNumberImage!, forResponseKey: currentField.responseKey!)
					return pictureCell
				}
			} else { // No picture available
				if let pictureCell = tableView.dequeueReusableCell(withIdentifier: TakePictureTableViewCell.identifier, for: indexPath) as? TakePictureTableViewCell {
					pictureCell.field = currentField
					pictureCell.delegate = self
					pictureCell.textFieldCallback = { [weak self] (value) in
						guard let weakSelf = self else { return }
						weakSelf.tempVehicle?.vin =  value
						ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: currentField.responseKey!)
						
					}
					pictureCell.valueField.placeholder = NSLocalizedString("vehicleinfo.vinnumber", comment: "VIN number")
					return pictureCell
				}
			}
        case .pictureType:
            if licensePlateImageAvailable {
                if let pictureCell = tableView.dequeueReusableCell(withIdentifier: LicenseTableViewCell.identifier, for: indexPath) as? LicenseTableViewCell {
                    pictureCell.item = currentField
                    
                    //delete the license plate pic
                    pictureCell.deletePictureCallBack = { [weak self] (value) in
                        guard let weakSelf = self else { return }
                        weakSelf.licensePlateImage = nil
                        weakSelf.licensePlateImageAvailable = false
                        weakSelf.tableView.reloadData()
                    }
                    //License field
                    pictureCell.textFieldCallback = { [weak self] (value) in
                        guard let weakSelf = self else { return }
                        weakSelf.tempVehicle?.licensePlate =  value
                        ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: currentField.responseKey!)
                    }
					pictureCell.valueTextField.placeholder = NSLocalizedString("vehicleinfo.licenseplatenumber", comment: "License plate number")
                    pictureCell.itemImageView.image = self.licensePlateImage
                    return pictureCell
                }
            } else { // No picture available
                if let pictureCell = tableView.dequeueReusableCell(withIdentifier: TakePictureTableViewCell.identifier, for: indexPath) as? TakePictureTableViewCell {
                    pictureCell.field = currentField
                    pictureCell.delegate = self
                    pictureCell.textFieldCallback = { [weak self] (value) in
                        guard let weakSelf = self else { return }
                        weakSelf.tempVehicle?.licensePlate =  value
                        ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: currentField.responseKey!)
                        
                    }
					pictureCell.valueField.placeholder = NSLocalizedString("vehicleinfo.licenseplatenumber", comment: "License plate number")
                    return pictureCell
                }
            }
			
		//Vehicle Year
        case .vehicleYearPicker:
            if let cell = tableView.dequeueReusableCell(withIdentifier: YearPicker.identifier, for: indexPath) as? YearPicker {
                cell.item = currentField
                if currentField.required == true {
                    cell.titleLabel.attributedText = Helper.requiredAttributedText(text:currentField.label!)}else{
                    cell.titleLabel.text = currentField.label
                }

				//TODO - API not returning actual values so just commented to for testing and make model are required as per API protocol.
//                if currentField.required {
				formValidator.registerField(cell.yearTextField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
//                }
				cell.yearTextField.placeholder = currentField.placeHolder
                //Call back for year picker to get selected value.
                cell.callback = {[weak self]  (value) in
                    // update the values after user selects year
                    guard let weakSelf = self else { return }
                    cell.yearTextField.text = value
                    weakSelf.selectedYear = value
                    weakSelf.isYearSelected = true
                    weakSelf.tempVehicle?.year = value
                    cell.errorLabel.text = ""
					ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: value, forResponseKey: currentField.responseKey!)
                    weakSelf.didYearValueChanged()
                }
                return cell
            }
			
		//Vehicle Make
        case .vehicleMakePickup:
            //if no year selected, hide the make cell
            if tempVehicle?.year == nil && NetworkReachability.isConnectedToNetwork() {
                return UITableViewCell()
            }
			var cell: MyVehicleRowCell!
			if NetworkReachability.isConnectedToNetwork() {
				cell = tableView.dequeueReusableCell(withIdentifier: MyVehicleRowCell.identifier, for: indexPath) as! MyVehicleRowCell
			} else {
				cell = tableView.dequeueReusableCell(withIdentifier: MyVehicleEditableRowCell.identifier, for: indexPath) as! MyVehicleEditableRowCell
				(cell as! MyVehicleEditableRowCell).delegate = self
			}
			cell.item = currentField
			cell.titleLabel.attributedText = Helper.requiredAttributedText(text:currentField.label!)

			//TODO - API not returning actual values so just commented to for testing and make model are required as per API protocol.
//          if currentField.required {
				formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
//			}
			makeCell = cell
			cell.valueField.placeholder = currentField.placeHolder
			return cell

		//Vehicle Model
        case .vehicleModelPickup:
            //if no make selected, hide the model cell
            if tempVehicle?.make == nil && NetworkReachability.isConnectedToNetwork() {
                return UITableViewCell()
            }
			var cell: MyVehicleRowCell!
			if NetworkReachability.isConnectedToNetwork() {
				cell = tableView.dequeueReusableCell(withIdentifier: MyVehicleRowCell.identifier, for: indexPath) as! MyVehicleRowCell
			} else {
				cell = tableView.dequeueReusableCell(withIdentifier: MyVehicleEditableRowCell.identifier, for: indexPath) as! MyVehicleEditableRowCell
				(cell as! MyVehicleEditableRowCell).delegate = self
			}
			cell.item = currentField
			modelCell = cell
			cell.titleLabel.attributedText = Helper.requiredAttributedText(text:currentField.label!)
			
			//TODO - API not returning actual values so just commented to for testing and make model are required as per API protocol.
//          if currentField.required {
			formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
//          }
			cell.valueField.placeholder = currentField.placeHolder
			return cell

		//Vehicle Colour
        case .pickList:
            if let cell = tableView.dequeueReusableCell(withIdentifier: MyVehicleRowCell.identifier, for: indexPath) as? MyVehicleRowCell {
                cell.item = currentField
                //if required add error handling
                if currentField.required {
                    formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
                }
                colourPickCell = cell
                cell.titleLabel.text = currentField.label
                cell.valueField.placeholder = currentField.placeHolder
                return cell
            }
        default:()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderFooterViewCell.identifier) as! HeaderFooterViewCell
        cell.delegate = self
        let border = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0.5))
        border.backgroundColor = .tgGray
        cell.addSubview(border)

		// Hardcoding this because it's confusing as it is in the Questionnaire
//        let currentField = (sectionFields?.filter{($0).typeEnum == .toggleType})?.first
//        cell.titleLabel.text = (currentField as AnyObject).label
		cell.titleLabel.text = NSLocalizedString("othervehicle.doyouhavevehicleinfo", comment: "Do you have the vehicle info?")
		
		cell.cellSegmentControl.items = [NSLocalizedString("alert.yes", comment: "Yes"), NSLocalizedString("alert.no", comment: "No")]
		cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentField = sectionFields![indexPath.row]
        guard let type = currentField.typeEnum else {
            return 0
        }
        switch  type {
            
        case .vehicleYearPicker: return dateCellExpanded ? datePickerRowHeightExpanded : defaultRowHeight
        case .pickList:
			return defaultRowHeight
        case .vehicleMakePickup:
            return (tempVehicle!.year == nil && NetworkReachability.isConnectedToNetwork()) ? 0.0 : defaultRowHeight
        case .vehicleModelPickup:
            return (tempVehicle!.make == nil && NetworkReachability.isConnectedToNetwork()) ? 0.0 : defaultRowHeight
		case .vinNumber:
			return vinImageAvailable ? expandedPhotoCellHeight : defaultRowHeight
        case .pictureType:
            return licensePlateImageAvailable ? expandedPhotoCellHeight : defaultRowHeight
        default:()
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ?  defaultRowHeight : 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableFooterView.identifier) as! TableFooterView
        footerCell.delegate = self
        footerCell.firstButtonText = NSLocalizedString("alert.cancel", comment: "Cancel")
        footerCell.nextButtonText = NSLocalizedString("myvehicle.toaddvehicle", comment: "Add Vehicle")
        footerCell.nextButton.isEnabled = true
        return footerCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return defaultFooterHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hidden[section] {
            return 0
        } else {
            return (sectionFields!.count)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let field = sectionFields?[indexPath.row],
            let type = field.typeEnum else { return }
        
        switch type {
        case .vehicleYearPicker:do{
            dateCellExpanded =  dateCellExpanded ? false : true
            tableView.reloadData()
            }
            
        case .vehicleMakePickup:do{
            if isYearSelected && NetworkReachability.isConnectedToNetwork() {
                LoadingView.show(inView: self.view, type: .hud, animated: true)
                //pick the make of the from year
                pickVehicleMake(forYear: selectedYear)
            }
            }
            
        case .vehicleModelPickup:do{
            if isYearSelected && isMakeSelected && NetworkReachability.isConnectedToNetwork() {
                LoadingView.show(inView: self.view, type: .hud, animated: true)
                //pick the model of the from make and year
                pickVehicleModel(forMake: selectedMake, forYear: selectedYear)
            }
            }
        case .pickList:do{
            LoadingView.show(inView: self.view, type: .hud, animated: true)
            pickVehicleColour()
            }
        default:()
        }
    }
    
}

extension VehicleInfoVC {
    
    func updaterecords(cellType: CellType, selectedValue: String) {
        
        switch cellType {
        // for make
        case .vehicleMakePickup:
            self.isMakeSelected = true
            self.selectedMake = selectedValue
            self.tempVehicle?.make = selectedValue
            self.didMakeValueChanged()
            self.tableView.reloadData()
            
        //for model
        case .vehicleModelPickup:
            self.isModelSelected = true
            self.selectedModel = selectedValue
            self.tempVehicle?.model = selectedValue
            self.tableView.reloadData()
            
        //For vehicle colour
        case .pickList:
            self.isColourSelected = true
            self.selectedColour = selectedValue
            self.tempVehicle?.colour = selectedValue
            
        default:()
        }
    }
    
    //reset Make, Model if year value changes
    func didYearValueChanged() {
        
        makeCell?.valueField.text = ""
        selectedMake = ""
        isMakeSelected = false
        modelCell?.valueField.text = ""
        selectedModel = ""
        isModelSelected = false
        tempVehicle?.make = nil
        tempVehicle?.model = nil
    }
    
    //reset if Model, if Make Changes
    func didMakeValueChanged() {
        
        modelCell?.valueField.text = ""
        selectedModel = ""
        isModelSelected = false
        tempVehicle?.model = nil
    }
    
    /// Pick vehicle make from the list
    ///
    /// - Parameters: year
    ///
    func pickVehicleMake(forYear: String) {
        self.pickerList.removeAll()
        
        ApplicationContext.shared.fnolClaimsManager.getMakesForYear(year: forYear, completion: { (innerClosure) in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                LoadingView.hide(inView: weakSelf.view, animated: true)
            }
            do{
                self.pickerList = try innerClosure()
                self.performSegue(withIdentifier: "showPickMakeModelVC", sender: self.makeCell)
            } catch let message {
                print(message)
            }
            
        })
    }
    
    /// Pick vehicle model
    ///
    /// - Parameters: make, year
    ///
    func pickVehicleModel(forMake: String, forYear: String) {
        self.pickerList.removeAll()
        
        ApplicationContext.shared.fnolClaimsManager.getModelsForMakesYear(make: forMake, year: forYear, completion: { (innerClosure) in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                LoadingView.hide(inView: weakSelf.view, animated: true)
            }
            do{
                self.pickerList = try innerClosure()
                self.performSegue(withIdentifier: "showPickMakeModelVC", sender: self.modelCell)
                
            } catch let message {
                print(message)
            }
            
        })
    }
    
    /// Pick vehicle colour
    ///
    /// - Parameters:
    ///
    func pickVehicleColour() {
        self.pickerList.removeAll()
        guard let colourField: [Field] = (currentSection?.fields?.filter{($0 as? Field)?.typeEnum == .pickList} as? [Field]) else{
            return
        }
        let fld = colourField.first
        for valObj in (fld?.validValues)! {
            self.pickerList.append((valObj as! Value).value!)
        }
        LoadingView.hide(inView: self.view, animated: true)
        self.performSegue(withIdentifier: "showPickMakeModelVC", sender: self.colourPickCell)
    }
}


extension VehicleInfoVC: FooterDelegate, UIValidationDelegate {
    
    func validationSuccessful() {
        // On successful validation , create mo_Vehicle
        let vehicle = FNOLVehicle.mr_createEntity()!
        vehicle.updateFromTemporaryCopy(temp: self.tempVehicle)
		ApplicationContext.shared.fnolClaimsManager.activeClaim?.addVehicle(vehicle)

		if let licensePlateImage = licensePlateImage {
			vehicle.setImage(licensePlateImage, imageType: .licensePlate)
		}
		if let vinNumberImage = vinNumberImage {
			vehicle.setImage(vinNumberImage, imageType: .vinNumber)
		}
        
        if !hasVehicleInfo {
			vehicle.make = "\(NSLocalizedString("vehicleinfo.unknownvehicle", comment: "Unknown Vehicle")) \(ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex)"
        }
        
        self.delegate?.didTouchonAddVehicle(vehicle: vehicle)
        ApplicationContext.shared.fnolClaimsManager.saveActiveClaim()
        self.navigationController?.popViewController(animated: true)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)]) {
        print("Validation failed")
        self.tableView.reloadData()
    }
    
    func didTouchLeftButton() {
		confirmDelete { [weak self] in
			guard let weakSelf = self else { return }
			weakSelf.navigationController?.popViewController(animated: true)
		}
    }
    
    //validate on success
    func didTouchRightButton() {
        if hasVehicleInfo {
            formValidator.validate(self)
        } else {
            tempVehicle = FNOLVehicleTemporary()
            validationSuccessful()
        }
    }
}

extension VehicleInfoVC: CollapsibleTableViewHeaderDelegate{
    
	func didTapOnTakePicture(isSelected: Bool, field: Field?) {
		if let field = field {
			if field.responseKey?.lowercased().range(of: ".vin") != nil {
				photoType = .vinNumber
			} else if field.responseKey?.range(of: "licensePlate") != nil {
				photoType = .licensePlate
			}
		}
        licensePlateImageAvailable = false
        let alert: UIAlertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let messageFont = [NSAttributedStringKey.font: UIFont.boldTitle]
        let messageAttrString = NSMutableAttributedString(string: NSLocalizedString("alert.accident.title", comment: ""), attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        // for Camera
        let cameraAction = UIAlertAction(title: NSLocalizedString("alert.accident.camera", comment: ""), style: UIAlertActionStyle.default){[weak self]  UIAlertAction in
            guard let weakSelf = self else { return }
            weakSelf.cameraAllowsAccessToApplicationCheck()
        }
        //for Photo gallery
        let gallaryAction = UIAlertAction(title: NSLocalizedString("alert.accident.gallery", comment: ""), style: UIAlertActionStyle.default){[weak self]  UIAlertAction in
            guard let weakSelf = self else { return }
            weakSelf.photoLibraryAvailabilityCheck()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("alert.cancel", comment: ""), style: UIAlertActionStyle.cancel){
            UIAlertAction in
        }
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Handle the Hide/Show Vehicle Info fields.
    func toggleSection(_ section: Int) {
        hasVehicleInfo = !hasVehicleInfo
        let indexPaths = (0..<(sectionFields?.count)!).map { i in
            return  IndexPath(item: i, section: section)}
        hidden[section] = !hidden[section]
        
        tableView?.beginUpdates()
        if hidden[section] {
            tableView?.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView?.insertRows(at: indexPaths, with: .fade)
            
        }
        tableView?.endUpdates()
    }
}

extension VehicleInfoVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}

extension VehicleInfoVC: MyVehicleEditableRowCellDelegate {
	
	func didUpdate(cell: MyVehicleEditableRowCell) {
		guard let responseKey = cell.item?.responseKey, let activeClaim = ApplicationContext.shared.fnolClaimsManager.activeClaim else { return }
		activeClaim.setValue(cell.valueField.text!, displayValue: nil, forResponseKey: responseKey)
	}
	
}
