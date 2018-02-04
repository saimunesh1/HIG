//
//  PickerVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PickerVC: UITableViewController {

    public var currentField: Field? {
        didSet {
            self.title = currentField?.title
        }
    }
    var selectedCellIndexPath: IndexPath?
    public var delegate: PickerDelegate?
	public var personPickerDelegate: PersonPickerVCDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PickerViewCell.nib, forCellReuseIdentifier: PickerViewCell.identifier)
    }
	
    @IBAction func goBack(segue: UIStoryboardSegue) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension PickerVC {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentField?.validValues?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PickerViewCell.identifier, for: indexPath) as! PickerViewCell
        let field = self.currentField?.validValuesArray![indexPath.row]
        cell.titleLabel.text = field?.value
        cell.checkImageView.isHidden = true // TODO: This should be based on the field's responsekey's value
        return cell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? PickerViewCell else { return }
        guard let selectedCode = self.currentField?.validValuesArray?[indexPath.row].code else { return }
        guard let selectedValue = self.currentField?.validValuesArray?[indexPath.row].value else { return }
        guard let fieldResponseKey = self.currentField?.responseKey else { return }
        
        // Check if we need to uncheck previous item
        if let selectedIndexPath = self.selectedCellIndexPath, selectedIndexPath != indexPath,
            let selectedCell = self.tableView.cellForRow(at: selectedIndexPath) as? PickerViewCell {
            selectedCell.checkImageView.isHidden = true
        }
        self.selectedCellIndexPath = indexPath
        if let subfield = self.currentField?.subFieldsArray?.first(where: { (field) -> Bool in
            if field.showValuesInNewPage == true {
                if let matchesParentResponseKey = field.rulesArray?.contains(where: { (rule) in
                    guard let parentResponseKey = rule.parentFieldResponseKey, fieldResponseKey == parentResponseKey else { return false }
                    
                    if let matchesParentValue = rule.parentValuesArray?.contains(where: { (parentValue) in
                        guard let parentValueCode = parentValue.value?.code else { return false }
                        return parentValueCode == selectedCode
                    }) { return matchesParentValue }
                    
                    return false
                }) { return matchesParentResponseKey }
                
                return false
            }
            return false
        }) {
			// self.delegate?.didPickSubField(code: selectedCode, value: selectedValue, responseKey: fieldResponseKey)
			cell.checkImageView.isHidden = false
			ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(selectedCode, displayValue: selectedValue, forResponseKey: fieldResponseKey)
			let pickerVC = UIStoryboard(name: "FNOL", bundle: nil).instantiateViewController(withIdentifier: "PickerVC") as! PickerVC
			pickerVC.currentField = subfield
            pickerVC.title = subfield.label
			pickerVC.delegate = delegate
			pickerVC.personPickerDelegate = self.personPickerDelegate
			self.navigationController?.pushViewController(pickerVC, animated: true)
		
		} else {
			
			// Just add checkmark
            cell.checkImageView.isHidden = false
            
           	// Remove existing value
			ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue("", displayValue: nil, forResponseKey: "accidentDetails.whatHappened.subType")

			//Save new value
			self.delegate?.didPickSubField(value: selectedCode, displayValue: selectedValue, responseKey: fieldResponseKey)
           
        }
    }
	
}

extension PickerVC: PersonInfoVCDelegate {
	
	func returnToOriginScreen() {
		navigationController?.popViewController(animated: false)
		navigationController?.popViewController(animated: true)
	}
	
	func didPick(person: FNOLPerson?) {
		if let person = person {
			personPickerDelegate?.didPick(person: person)
		}
	}

}

extension PickerVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}
