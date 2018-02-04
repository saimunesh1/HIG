//
//  OtherVehicleVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/5/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class OtherVehicleVC: PhotoPickViewController {
    
    @IBOutlet var tableView: UITableView!

	public var delegate: VehicleListFooterDelegate?
	public var viewModel: Questionnaire?

	private var colourPickCell: MyVehicleRowCell? = nil
	private var currentSection: Section?
	private var dateCellExpanded: Bool = false
	private var hasVehicleInfo = false
	private var hidden = true
	private var isColourSelected: Bool = false
	private var isLicensePlateImageAvailable: Bool = false
	private var isMakeSelected: Bool = false
	private var isModelSelected: Bool = false
	private var isYearSelected: Bool = false
	private var licensePlateImage: UIImage?
	private var makeCell: MyVehicleRowCell? = nil
	private var modelCell: MyVehicleRowCell? = nil
	private var pickerCell: MyVehicleRowCell?
	private var pickerList: [String] = []
	private var sectionFields: [Field]?
	private var selectedField: Field?
	private var tableRows: [Field]?
	private var tempVehicle: FNOLVehicleTemporary!
	private var thisVehicle: FNOLVehicle?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        tempVehicle = FNOLVehicleTemporary()
        registerNibs()
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
		navigationItem.title = NSLocalizedString("claimreview.vehicle", comment: "Vehicle") + " \(ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender: )), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender: )), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        guard let list = self.viewModel?.getSectionList(pageID: "vehicle_2_details") else { return }
		self.currentSection = list[0]
        
        // Workaround for hiding Colour field
        sectionFields = list.first?.fields?.filter{($0 as! Field).typeEnum != .pickList} as? [Field]
        
        // Workaround for showing Colour field and order of the data and VIN field
        handleDataSourceForVehicle()

		loadFromCoreData {
			self.updateSection(section: 0)
			self.tableView.reloadData()
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
            topBarView.setCurrentPage(self.pageType)
        }
		self.tableView.reloadData()
	}
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func registerNibs() {
        tableView.register(LicenseTableViewCell.nib, forCellReuseIdentifier: LicenseTableViewCell.identifier)
        tableView.register(TakePictureTableViewCell.nib, forCellReuseIdentifier: TakePictureTableViewCell.identifier)
		tableView.register(MyVehicleRowCell.nib, forCellReuseIdentifier: MyVehicleRowCell.identifier)
		tableView.register(MyVehicleEditableRowCell.nib, forCellReuseIdentifier: MyVehicleEditableRowCell.identifier)
        tableView.register(HeaderFooterViewCell.nib, forHeaderFooterViewReuseIdentifier: HeaderFooterViewCell.identifier)
        tableView.register(YearPicker.nib, forCellReuseIdentifier: YearPicker.identifier)
        tableView.register(TableFooterView.nib, forHeaderFooterViewReuseIdentifier: TableFooterView.identifier)
    }
	
    func handleDataSourceForVehicle() {
        tableRows = (sectionFields?.filter{($0 ).typeEnum != .toggleType && ($0 ).typeEnum != .vehicleYearPicker})
        let yearField: [Field] = (sectionFields?.filter{($0).typeEnum == .vehicleYearPicker})!
        tableRows?.insert(yearField.first!, at: 1)
        guard let colourIdx = tableRows?.count else { return }
        let colourField: [Field] = (currentSection?.fields?.filter{($0 as! Field).typeEnum == .pickList } as! [Field])
        tableRows?.insert(colourField.first!, at: colourIdx - 1 )
    }
	
	private func loadFromCoreData(completion: (() -> Void)?) {
		if let thisVehicle = ApplicationContext.shared.fnolClaimsManager.currentVehicle {
			self.thisVehicle = thisVehicle
			self.tempVehicle = thisVehicle.temporaryCopy()
			hasVehicleInfo = thisVehicle.year != nil
			if let image = thisVehicle.licensePlateImage?.image {
				licensePlateImage = image
				isLicensePlateImageAvailable = true
			}
			// Make sure vehicle rows hide/show appropriately
			if (!hasVehicleInfo && !hidden) || (hasVehicleInfo && hidden) {
				updateSection(section: 0)
			}
		} else {
			tempVehicle = FNOLVehicleTemporary()
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? PersonPickerVC {
			vc.personPickerDelegate = self
			vc.personInfoType = .owner
			vc.isOwner = true
			vc.currentField = StateManager.instance.driverInfoField
			return
		}
		let cell = sender as? MyVehicleRowCell
		guard let type = cell?.item?.typeEnum else {
            if segue.identifier == "showPeopleInVehicleVC" {
                let vc  = segue.destination as! PeopleInVehicleVC
                vc.viewModel = self.viewModel
            }
            return
		}
		if (segue.identifier == "showPickMakeModelVC") {
			let vc = segue.destination as! PickMakeModelVC
			vc.navigationItem.title = "\(cell?.item?.label ?? "")"
			vc.dataSourceArray = self.pickerList
			vc.callback = { (value) in
				self.updaterecords(cellType: type, selectedValue: value)
				if cell?.item?.responseKey == "otherVehicle.colour" {
					self.tempVehicle.colour = value
				}
				ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: (cell?.item?.responseKey!)!)
				cell?.valueField.text = value
				cell?.errorLabel.text = ""
			}
		} else if let vc = segue.destination as? SupportVC {
			vc.contextualHelpString = NSLocalizedString("contextualhelp.othervehicle", comment: "")
		}
	}
	
    override func goBack(segue: UIStoryboardSegue) {
		if ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex > 1 {
			ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex -= 1
		}
		super.goBack(segue: segue)
    }

    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		let image = info[UIImagePickerControllerOriginalImage] as! UIImage
		isLicensePlateImageAvailable = true
		licensePlateImage = image
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

}

extension OtherVehicleVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentField = tableRows![indexPath.row]
        guard let type = currentField.typeEnum else {
            return UITableViewCell()
        }
        switch type {
            
        case .pictureType:
			var licensePlateNumber = ""
			if let number = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: currentField.responseKey!) {
				licensePlateNumber = number
			}
            if isLicensePlateImageAvailable {
                if let pictureCell = tableView.dequeueReusableCell(withIdentifier: LicenseTableViewCell.identifier, for: indexPath) as? LicenseTableViewCell {
                    pictureCell.item = currentField
					pictureCell.valueTextField.text = licensePlateNumber
                    pictureCell.deletePictureCallBack = { [weak self] (value) in
                        guard let weakSelf = self else { return }
                        weakSelf.licensePlateImage = nil
                        weakSelf.isLicensePlateImageAvailable = false
                        weakSelf.tableView.reloadData()
					}
                    pictureCell.textFieldCallback = { [weak self] (value) in
                        guard let weakSelf = self else { return }
                        weakSelf.tempVehicle?.licensePlate =  value
                        ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: currentField.responseKey!)
                    }
                    pictureCell.itemImageView.image = self.licensePlateImage
                    //add license plate image to claim
                    ApplicationContext.shared.fnolClaimsManager.activeClaim?.setImage(self.licensePlateImage!, forResponseKey: currentField.responseKey!)
                    return pictureCell
                }
                
            } else { // No license plate image available
				
                if let pictureCell = tableView.dequeueReusableCell(withIdentifier: TakePictureTableViewCell.identifier, for: indexPath) as? TakePictureTableViewCell {
                    pictureCell.field = currentField
                    pictureCell.delegate = self
					pictureCell.valueField.text = licensePlateNumber
                    pictureCell.textFieldCallback = { [weak self] (value) in
                        guard let weakSelf = self else { return }
                        weakSelf.tempVehicle?.licensePlate =  value
                        ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: currentField.responseKey!)
                        
                    }
                    return pictureCell
                }
            }
			
        case .vehicleYearPicker:
            if let cell = tableView.dequeueReusableCell(withIdentifier: YearPicker.identifier, for: indexPath) as? YearPicker {
                cell.item = currentField
				cell.titleLabel.attributedText = Helper.requiredAttributedText(text:currentField.label!)
                cell.yearTextField.placeholder = currentField.placeHolder
				cell.yearTextField.text = self.tempVehicle.year
				
                //TODO - API not returning actual values so just commented to for testing and make model are required as per API protocol.
//                if currentField.required {
                    formValidator.registerField(cell.yearTextField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
//                }
                cell.callback = {[weak self]  (value) in
                    guard let weakSelf = self else { return }
                    cell.yearTextField.text = value
					weakSelf.tempVehicle.year = value
                    ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: currentField.responseKey!)
                    weakSelf.isYearSelected = true
                    cell.errorLabel.text = ""
                    weakSelf.tempVehicle?.year = value
                    weakSelf.didYearValueChanged()
                }
                return cell
            }

		case .vehicleMakePickup:
			if tempVehicle.year == nil && NetworkReachability.isConnectedToNetwork() {
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
//          }
			makeCell = cell
			cell.valueField.placeholder = currentField.placeHolder
			cell.valueField.text = tempVehicle.make?.lowercased().capitalized
			return cell
			
        case .vehicleModelPickup:
			if tempVehicle.make == nil && NetworkReachability.isConnectedToNetwork() {
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
//          }
			modelCell = cell
			cell.valueField.placeholder = currentField.placeHolder
			cell.valueField.text = tempVehicle.model?.lowercased().capitalized
			return cell
			
        case .pickList:
            if let cell = tableView.dequeueReusableCell(withIdentifier: MyVehicleRowCell.identifier, for: indexPath) as? MyVehicleRowCell {
                cell.item = currentField
                if currentField.required {
                    formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
                }
                colourPickCell = cell
                cell.titleLabel.text = currentField.label
                cell.valueField.placeholder = currentField.placeHolder
				if let colour = tempVehicle.colour {
					cell.valueField.text = colour
				}
                return cell
            }
			
		case .ownerPickList:
			if let cell = tableView.dequeueReusableCell(withIdentifier: MyVehicleRowCell.identifier, for: indexPath) as? MyVehicleRowCell {
				cell.item = currentField
				if currentField.required {
					formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
				}
				colourPickCell = cell
				cell.titleLabel.text = currentField.label
				cell.valueField.placeholder = currentField.placeHolder
				if let owner = tempVehicle.owner {
					cell.valueField.text = "\(owner.firstName ?? "") \(owner.lastName ?? "")".initialCapped
				}
				return cell
			}
			
        case .severityPickList:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeverityDamageCellID", for: indexPath) as! SeverityDamageCell
            cell.titleLabel.text = currentField.label
            cell.selectionStyle = .none
			if let severity = tempVehicle.damageSeverity {
				if let severityIndex = DamageSeverity.allValues.index(of: severity) {
					cell.indexNumber = severityIndex
				} else {
					cell.indexNumber = -1
				}
				cell.collectionView.reloadData()
			}
            cell.callback = { (value) in
				self.tempVehicle.damageSeverity = value
                ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: currentField.responseKey!)
            }
            return cell
            
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
		cell.cellSegmentControl.selectedIndex = hasVehicleInfo ? 0 : 1
		cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentField = tableRows![indexPath.row]
        guard let type = currentField.typeEnum else {
            return 0
        }
        switch  type {
            
        case .vehicleYearPicker:
			return dateCellExpanded ? datePickerRowHeightExpanded : defaultRowHeight
		case .vehicleMakePickup:
			return ((tempVehicle.year == nil || tempVehicle.year == YearPicker.iDontKnow) && NetworkReachability.isConnectedToNetwork()) ? 0.0 : defaultRowHeight
		case .vehicleModelPickup:
			return (tempVehicle.make == nil && NetworkReachability.isConnectedToNetwork()) ? 0.0 : defaultRowHeight
		case .pickList, .ownerPickList:
            return defaultRowHeight
        case .pictureType :
            return isLicensePlateImageAvailable ? expandedPhotoCellHeight : defaultRowHeight
        case .severityPickList:
            return  severeDamageCellHeight
            
        default:()
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ?  defaultRowHeight : 0.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hidden {
            return 0
        } else {
            return (tableRows!.count)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let field = tableRows?[indexPath.row],
            let type = field.typeEnum else { return }
        
        switch type {
        case .vehicleYearPicker:
            dateCellExpanded =  dateCellExpanded ? false : true
            tableView.reloadData()
        case .vehicleMakePickup:
            if isYearSelected && NetworkReachability.isConnectedToNetwork() {
                LoadingView.show(inView: self.view, type: .hud, animated: true)
                pickVehicleMake(forYear: tempVehicle.year!)
            }
        case .vehicleModelPickup:
            if isYearSelected && isMakeSelected && NetworkReachability.isConnectedToNetwork() {
                LoadingView.show(inView: self.view, type: .hud, animated: true)
                pickVehicleModel(forMake: tempVehicle.make!, forYear: tempVehicle.year!)
            }
        case .pickList:
            LoadingView.show(inView: self.view, type: .hud, animated: true)
            pickVehicleColour()
		case .ownerPickList:
			let cell = tableView.cellForRow(at: indexPath) as! MyVehicleRowCell
			self.pickerCell = cell
			performSegue(withIdentifier: "showPersonPickerVC", sender: nil)
        case .severityPickList: ()
        default:()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableFooterView.identifier) as! TableFooterView
        footerCell.delegate = self
		footerCell.firstButtonText = NSLocalizedString("footer.savequit", comment: "Save/Quit")

		// Dynamic footer cell button name based on vehicle count
		if let vehicleCount = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "claim.vehicleCount") {
			let count = Int(vehicleCount) ?? -1
			if vehicleCount == "insured_vehicle_only" || ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex >= count {
				footerCell.nextButtonText = NSLocalizedString("people.people", comment: "People")
			} else {
				footerCell.nextButtonText = NSLocalizedString("footer.nextvehicle", comment: "Next vehicle")
			}
		}
        footerCell.nextButton.isEnabled = true
        return footerCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return defaultFooterHeight
    }
    
}


extension OtherVehicleVC: FooterDelegate, UIValidationDelegate {
    
    func validationSuccessful() {
		var vehicle: FNOLVehicle!
		if let thisVehicle = thisVehicle {
			thisVehicle.updateFromTemporaryCopy(temp: self.tempVehicle)
			vehicle = thisVehicle
		} else if let thisVehicle = ApplicationContext.shared.fnolClaimsManager.currentVehicle {
			self.thisVehicle = thisVehicle
			thisVehicle.updateFromTemporaryCopy(temp: self.tempVehicle)
			vehicle = thisVehicle
		} else {
			let newVehicle = FNOLVehicle.mr_createEntity()!
			newVehicle.updateFromTemporaryCopy(temp: self.tempVehicle)
			ApplicationContext.shared.fnolClaimsManager.activeClaim?.addVehicle(newVehicle)
			vehicle = newVehicle
		}
        vehicle.indexInClaim = ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex

		// Add or update licensePlateImage
		if let image = licensePlateImage {
			if vehicle.licensePlateImage != nil {
				vehicle.licensePlateImage!.image = image
			} else {
				vehicle.setImage(image, imageType: .licensePlate)
			}
		} else { // No image -- delete existing FNOLImage (if any)
			if vehicle.licensePlateImage != nil {
				vehicle.licensePlateImage!.mr_deleteEntity()
			}
		}

		if !hasVehicleInfo {
			vehicle.make = "\(NSLocalizedString("vehicleinfo.unknownvehicle", comment: "Unknown Vehicle")) \(ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex)"
		}
		
        // Go to next screen
		self.performSegue(withIdentifier: "showPeopleInVehicleVC", sender: self)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)]) {
        print("Validation failed")
        self.tableView.reloadData()
    }
    
    func didTouchLeftButton() {
		showSaveQuitActionSheet()
		
		// Handles removing the top-bar when user navigates back
		if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
			self.supplementalNavigationController?.removeSupplementalView(topBarView, animated: false)
		}
    }
    
    func didTouchRightButton() {
		if hasVehicleInfo {
			formValidator.validate(self)
		} else {
			// Don't have vehicle info -- just save an empty vehicle
			tempVehicle = FNOLVehicleTemporary()
			validationSuccessful()
		}
    }
    
}

extension OtherVehicleVC {
    
    func updaterecords(cellType: CellType, selectedValue: String) {
        switch cellType {
        case .vehicleMakePickup:
            self.isMakeSelected = true
            self.tempVehicle.make = selectedValue
            self.didMakeValueChanged()
            
        case .vehicleModelPickup:
            self.isModelSelected = true
            self.tempVehicle.model = selectedValue
            
        case .pickList:
            self.isColourSelected = true
			self.tempVehicle.colour = selectedValue
			
        default:()
        }
    }
    
    func didYearValueChanged() {
        makeCell?.valueField.text = ""
        tempVehicle.make = nil
        isMakeSelected = false
		
        modelCell?.valueField.text = ""
        tempVehicle.model = nil
        isModelSelected = false

		tableView.reloadData()
    }
    
    func didMakeValueChanged() {
        modelCell?.valueField.text = ""
        tempVehicle.model = nil
        isModelSelected = false
    }
    
    func pickVehicleMake(forYear: String) {
        self.pickerList.removeAll()
        ApplicationContext.shared.fnolClaimsManager.getMakesForYear(year: forYear, completion: { (innerClosure) in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                LoadingView.hide(inView: weakSelf.view, animated: true)
            }
            do {
                self.pickerList = try innerClosure()
                self.performSegue(withIdentifier: "showPickMakeModelVC", sender: self.makeCell)
                
            } catch let message {
                print(message)
            }
        })
    }
    
    func pickVehicleModel(forMake: String, forYear: String) {
        self.pickerList.removeAll()
        ApplicationContext.shared.fnolClaimsManager.getModelsForMakesYear(make: forMake, year: forYear, completion: { (innerClosure) in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                LoadingView.hide(inView: weakSelf.view, animated: true)
            }
            do {
                self.pickerList = try innerClosure()
                self.performSegue(withIdentifier: "showPickMakeModelVC", sender: self.modelCell)
                
            } catch let message {
                print(message)
            }
        })
    }
    
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

extension OtherVehicleVC: CollapsibleTableViewHeaderDelegate{
    
	func didTapOnTakePicture(isSelected: Bool, field: Field?) {
        isLicensePlateImageAvailable = false
        let alert: UIAlertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let messageFont = [NSAttributedStringKey.font: UIFont.boldTitle]
        let messageAttrString = NSMutableAttributedString(string: NSLocalizedString("alert.accident.title", comment: ""), attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        let cameraAction = UIAlertAction(title: NSLocalizedString("alert.accident.camera", comment: ""), style: UIAlertActionStyle.default){[weak self]  UIAlertAction in
            guard let weakSelf = self else { return }
            weakSelf.cameraAllowsAccessToApplicationCheck()
        }
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
    
    func toggleSection(_ section: Int) {
		hasVehicleInfo = !hasVehicleInfo
		self.updateSection(section: section)
	}
	
	private func updateSection(section: Int) {
        let indexPaths = (0..<(tableRows?.count)!).map { i in
            return IndexPath(item: i, section: section)
		}
        hidden = !hidden
		
        tableView?.beginUpdates()
        if hidden {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue("yes", displayValue: nil, forResponseKey: "otherVehicle.doesntHaveVehicleInfo")
            tableView?.deleteRows(at: indexPaths, with: .fade)
        } else {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue("no", displayValue: nil, forResponseKey: "otherVehicle.doesntHaveVehicleInfo")
            tableView?.insertRows(at: indexPaths, with: .fade)
        }
        tableView?.endUpdates()
    }
}

extension OtherVehicleVC: FNOLTopBarNavigatable {
    var pageType: FNOLTopBarPageType {
        return .vehicle(number: Int(ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex))
    }
}

extension OtherVehicleVC: PersonPickerVCDelegate {
	
	func didPick(person: FNOLPerson?) {
		if let person = person {
			person.vehicle = ApplicationContext.shared.fnolClaimsManager.currentVehicle
			if person.isOwner {
				tempVehicle.owner = person
			}
			if person.isDriver {
				tempVehicle.driver = person
			}
		}
	}

}

extension OtherVehicleVC: MyVehicleEditableRowCellDelegate {

	func didUpdate(cell: MyVehicleEditableRowCell) {
		ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(cell.valueField.text!, displayValue: nil, forResponseKey: (cell.item?.responseKey!)!)
	}

}
