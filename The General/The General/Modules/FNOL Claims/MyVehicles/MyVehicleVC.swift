//
//  MyVehicleVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/12/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import MagicalRecord

class MyVehicleVC: FNOLBaseVC, UIValidationDelegate {
    
    public var currentSection: Section?
    public var viewModel: Questionnaire?
    public var sectionsList: [Section] = []
    public var sectionFields: [Field]?
    public var vehicleCount: Int?
	
    private var owner: FNOLPerson?
    private var currentVehicle: FNOLVehicle?
    private var driverObject: [Field]?
    private var pickerCell: MyVehicleRowCell?
    private var vehicleCell: VehiclePickCell?
    private var damagedPartsAdded: [FNOLDamagedPart] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ApplicationContext.shared.fnolClaimsManager.currentVehicleIndex = 1
        loadFromCoreData {
            self.tableView.reloadData()
        }
    }
    
    func setupTableView() {
        registerNibs()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        guard let list = self.viewModel?.getSectionList(pageID: "my_vehicle_details") else {
            return
        }
        self.currentSection = list[0]
        self.sectionsList = list
        
        // Workaround for hiding Colour field
        sectionFields = self.sectionsList.first?.fields?.filter{($0 as! Field).typeEnum != .pickList} as? [Field]
    }
    
    static func instantiate() -> MyVehicleVC {
        let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! MyVehicleVC
        return vc
    }
    
    private func loadFromCoreData(completion: (() -> Void)?) {
        
        // If we don't have any PersonInfo objects yet, create them from the DriverInfo objects in the Questionnaire
        // TODO: Move this somewhere where it makes more sense
		guard let activeClaim = ApplicationContext.shared.fnolClaimsManager.activeClaim else { return }
		let predicate: NSPredicate = NSPredicate(format: "claim == %@", activeClaim)
		let fnolPeople = (FNOLPerson.mr_findAll(with: predicate) as? [FNOLPerson]) ?? []
        if fnolPeople.count < 1 {
            let driverInfos = (DriverInfo.mr_findAll() as? [DriverInfo]) ?? []
            for driverInfo in driverInfos {
                let person: FNOLPerson = FNOLPerson.mr_createEntity()!
				person.populateFrom(driverInfo: driverInfo)
				activeClaim.addPerson(person)
                person.vehicle?.claim = ApplicationContext.shared.fnolClaimsManager.activeClaim
                completion?()
            }
        } else {
            fetchMyVehicleAndOwner(completion: completion)
        }
    }
    
    private func fetchMyVehicleAndOwner(completion: (() -> Void)?) {
		if currentVehicle == nil {
			if let activeClaim = ApplicationContext.shared.fnolClaimsManager.activeClaim {
				let predicate: NSPredicate = NSPredicate(format: "claim == %@", activeClaim)
				let allVehicles = (FNOLVehicle.mr_findAll(with: predicate) as? [FNOLVehicle]) ?? []
				if let myVehicle = allVehicles.filter({ $0.indexInClaim == 1 }).first {
					self.currentVehicle = myVehicle
				}
			}
		}
		if owner == nil {
			if let currentVehicle = self.currentVehicle, let people = currentVehicle.people?.allObjects as? [FNOLPerson] {
				if let owner = people.first(where: { $0.isOwner }) {
					self.owner = owner
				}
			}
		}
		completion?()
    }
    
    func registerNibs() {
        tableView.register(VehiclePickCell.nib, forCellReuseIdentifier: VehiclePickCell.identifier)
        tableView.register(MyVehicleRowCell.nib, forCellReuseIdentifier: MyVehicleRowCell.identifier)
        tableView.register(TableFooterView.nib, forHeaderFooterViewReuseIdentifier: TableFooterView.identifier)
    }
    
    func validationSuccessful() {
        self.performSegue(withIdentifier: "showPeopleInVehicleVC", sender: self)
        
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)]) {
        print("Validation failed")
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPeopleInVehicleVC" {
            if let owner = owner {
				owner.isOwner = true
            }
            let vc  = segue.destination as! PeopleInVehicleVC
            vc.viewModel = self.viewModel
        } else if segue.identifier == "showVehicleListVC" {
            let vc  = segue.destination as! VehicleListVC
            vc.viewModel = self.viewModel
            
            // When the user chooses a vehicle as My Vehicle:
            vc.callbackForVehicleInfo = { [weak self] (selectedVehicle) in
				guard let weakSelf = self else { return }
                
				// If we already have a vehicle with an owner, remove the owner from the vehicle
				if let vehicle = weakSelf.currentVehicle {
					if let previousOwner = vehicle.owner {
						previousOwner.isOwner = false
						previousOwner.vehicle = nil
						vehicle.owner = nil
					}
					// Remove the vehicle from the accident
					vehicle.indexInClaim = 0 // Not in accident
				}
				
				// Assign the selected vehicle as My Vehicle
				weakSelf.currentVehicle = selectedVehicle as FNOLVehicle
				weakSelf.currentVehicle?.indexInClaim = 1 // 1 = My Vehicle

				// Assign the current owner (if any) to the vehicle
				if let owner = weakSelf.owner {
					weakSelf.currentVehicle?.owner = owner
					owner.vehicle = weakSelf.currentVehicle
				}

				// Update UI
				let value = "\(weakSelf.currentVehicle?.make ?? "") \( weakSelf.currentVehicle?.model ?? "") \( weakSelf.currentVehicle?.year ?? "") \( weakSelf.currentVehicle?.licensePlate ?? "")"
                weakSelf.vehicleCell?.valueField.textColor = .black
                weakSelf.vehicleCell?.valueField.text  = value
                weakSelf.vehicleCell?.errorLabel.text = ""
            }
        } else if segue.identifier == "showDamageMapVC" {
            let vc  = segue.destination as! DamageMapVC
            vc.viewModel = self.viewModel
        } else if segue.identifier == "showDamageDetailsVC" {
            let vc  = segue.destination as! DamageDetailsVC
            vc.viewModel = self.viewModel!
        } else if segue.identifier == "showConditionLocationVC" {
            let vc = segue.destination as! ConditionLocationVC
            vc.viewModel = self.viewModel!
        } else if segue.identifier == "showPersonPickerVC" {
            if let vc = segue.destination as? PersonPickerVC {
                vc.delegate = self
				vc.personPickerDelegate = self
                vc.isOwner = true
				if let field = sender as? Field {
					vc.currentField = field
				}
            }
		} else if let vc = segue.destination as? SupportVC {
			vc.contextualHelpString = NSLocalizedString("contextualhelp.myvehicle", comment: "")
		}
    }
    
    // show the number of Damaged parts on MyVehicle Screen
    func prepareDamageMap(forCell: MyVehicleRowCell) {
        
        //Clear the container Array
        damagedPartsAdded.removeAll()
        
        //fetch From CoreData
        guard let partsList =  ApplicationContext.shared.fnolClaimsManager.activeClaim?.damagedParts?.array else {
            return
        }
        damagedPartsAdded = partsList as! [FNOLDamagedPart]
        if damagedPartsAdded.filter({$0.images != nil}).count > 0 {
            forCell.valueField.text = damagedPartsAdded.count > 1 ? "\( damagedPartsAdded.count) \(NSLocalizedString("label.parts", comment: ""))" : "\( damagedPartsAdded.count) \(NSLocalizedString("label.parts", comment: ""))"
        }else{
            forCell.valueField.placeholder =  forCell.item?.placeHolder
            forCell.valueField.text = ""
        }
    }
    
}


extension MyVehicleVC: PickerDelegate {
    
    func didAccidentPhotosPicked(imageArray: [FNOLImage]) {}
    
	func didPickSubField(value: String, displayValue: String, responseKey: String) {
        pickerCell?.item?.defaultValue = value
        ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: responseKey)
    }
    
}

extension MyVehicleVC: FooterDelegate {
    
    func didTouchLeftButton() {
		showSaveQuitActionSheet()
		
        // Handles removing the top-bar when user navigates back
        if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
            self.supplementalNavigationController?.removeSupplementalView(topBarView, animated: false)
        }
    }
    
    func didTouchRightButton() {
        
        //TODO: temporary hack for MyVehicle Error Validation
        if self.vehicleCell?.field?.required == true {
            formValidator.validate(self)
        } else {
            if self.currentVehicle == nil {
                self.vehicleCell?.errorLabel.text = NSLocalizedString("error.handling.required", comment: "This field is required")
                return
            } else {
                self.vehicleCell?.errorLabel.text = ""
                formValidator.validate(self)
            }
        }
    }
}

extension MyVehicleVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionFields?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentField = sectionFields![indexPath.row]
        guard let type = currentField.typeEnum else {
            return UITableViewCell()
        }
        switch type {
        case .vehiclePickList:
            if let cell = tableView.dequeueReusableCell(withIdentifier: VehiclePickCell.identifier, for: indexPath) as? VehiclePickCell {
				cell.valueSubField.text = ""
                cell.field = currentField
				if let label = currentField.label {
					cell.titleLabel.attributedText = Helper.requiredAttributedText(text: label)
				}
				if let currentVehicle = currentVehicle {
                    let value = "\(currentVehicle.make ?? "") \(currentVehicle.model ?? "") \(currentVehicle.year ?? "") \(currentVehicle.licensePlate ?? "") "
					cell.titleLabel.attributedText = Helper.requiredAttributedText(text: NSLocalizedString("myvehicle.vehicleinvolved", comment: "Vehicle involved"))
                    cell.valueField.text = value.initialCapped
					if let licensePlate = currentVehicle.licensePlate, !licensePlate.isEmpty {
						cell.valueSubField.text = "License plate: \(licensePlate)"
					}
                }
                self.vehicleCell = cell
                return cell
            }
            
        case .damagePickList, .damageDetailPickList, .vehicleConditionLocation, .ownerPickList:
            if let cell = tableView.dequeueReusableCell(withIdentifier: MyVehicleRowCell.identifier, for: indexPath) as? MyVehicleRowCell {
                cell.item = currentField
                if currentField.required {
                    cell.titleLabel.attributedText = Helper.requiredAttributedText(text:currentField.label!)}else{
                    cell.titleLabel.text = currentField.label}
                cell.valueField.placeholder = currentField.placeHolder
                
                // fetch the imagelist and update in MyVehicle Section
                if type == .damagePickList {
                    _ =  prepareDamageMap(forCell:cell)
                }
                
                if type == .ownerPickList, let firstName = owner?.firstName, let lastName = owner?.lastName {
                    cell.valueField.text = "\(firstName.initialCapped) \(lastName.initialCapped)"
                    cell.errorLabel.text = ""
                }
                return cell
            }
			
        default:()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentField = sectionFields![indexPath.row]
        guard let type = currentField.typeEnum else {
            return 0.0
        }
        switch type {
        case .vehiclePickList: return UITableViewAutomaticDimension
            
        case .damagePickList, .damageDetailPickList, .vehicleConditionLocation, .ownerPickList:
            return defaultRowHeight
        default: return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return defaultFooterHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableFooterView.identifier) as! TableFooterView
        footerCell.delegate = self
        footerCell.firstButtonText = NSLocalizedString("footer.savequit", comment: "Save/Quit")
        footerCell.nextButtonText = NSLocalizedString("footer.nextpeople", comment: "Next: People")
        footerCell.nextButton.isEnabled = true  //owner != nil
        return footerCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentField = sectionFields![indexPath.row]
        
        guard let type = currentField.typeEnum else {
            return
        }
        
        switch  type {
        case .vehiclePickList:do{
            guard let cell = tableView.cellForRow(at: indexPath) as? VehiclePickCell else {
                return
            }
            self.vehicleCell = cell
            self.performSegue(withIdentifier: "showVehicleListVC", sender: currentField)
            }
        case.damagePickList: do {
            guard let cell = tableView.cellForRow(at: indexPath) as? MyVehicleRowCell else {
                return
            }
            self.pickerCell = cell
            self.performSegue(withIdentifier: "showDamageMapVC", sender: self)
            }
        case .damageDetailPickList: do {
            self.performSegue(withIdentifier: "showDamageDetailsVC", sender: self)
            }
        case .vehicleConditionLocation: do {
            self.performSegue(withIdentifier: "showConditionLocationVC", sender: self)
            }
        case .ownerPickList:
            guard let cell = tableView.cellForRow(at: indexPath) as? MyVehicleRowCell else {
                return
            }
            self.pickerCell = cell
            self.performSegue(withIdentifier: "showPersonPickerVC", sender: currentField)
        default:()
        }
    }
    
}

extension MyVehicleVC: PersonPickerVCDelegate {
	
	func didPick(person: FNOLPerson?) {
		if let person = person {
			guard let activeClaim = ApplicationContext.shared.fnolClaimsManager.activeClaim else { return }
			activeClaim.addPerson(person)
			
			// If we've already selected an owner, remove them
			if let previousOwner = self.owner {
				previousOwner.isOwner = false
				previousOwner.vehicle = nil
			}
			
			// Assign new owner
			owner = person
			owner?.isOwner = true
			
			// If a vehicle is selected, assign the owner to it
			if let currentVehicle = currentVehicle {
				currentVehicle.owner = owner
				owner?.vehicle = currentVehicle
			}
		}
	}
	
}
