//
//  AddressFormVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/19/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AddressFormVC: UITableViewController, UIValidationDelegate {
    
    var delegate: AddressLocationDelegate?
    var addressFieldFromQuestionnaire: Field?
    var currentAddress =  FNOLAddressTemporary()
    var subFields = [Field]()
    let formValidator = FormErrorValidator()

    private func updateView() {
        self.title = NSLocalizedString("accidentdetails.address.title", comment: "")
        
        self.tableView.reloadData()
    }
    
	private let defaultFooterHeight: CGFloat = 90.0

    private var claim: FNOLClaim? {
        get {
            return ApplicationContext.shared.fnolClaimsManager.activeClaim
        }
    }

	override func viewDidLoad() {
        super.viewDidLoad()
        formValidator.styleTransformers(success: { (validationRule) -> Void in
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
        }, error:{ (validationError) -> Void in
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        })
        
        tableView.register(TableFooterView.nib, forHeaderFooterViewReuseIdentifier: TableFooterView.identifier)
        initContent()
        
        self.updateView()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = NSLocalizedString("accidentdetails.address.title", comment: "")
    }
	
    func initContent() {
        
        guard let tempFields = self.addressFieldFromQuestionnaire?.subFields else {
            return
        }
        for eachfield in tempFields {
            let currenField = eachfield as? Field
            if currenField?.responseKey != "accidentDetails.address.addressDetail2" {
                self.subFields.append(currenField!)
            }
        }
        // for Mile Marker/ Land mark placeholder
        updatePlaceHolders()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    @IBAction func goBack(segue: UIStoryboardSegue) {
        showConfirmAlert()
    }
   
    func saveAddressDetails() {
        self.delegate?.onTouchOnSave(addressInfo: self.currentAddress)
        self.currentAddress.storeAccidentDetailsAddress()
        self.navigationController?.popViewController(animated: true)
    }
    
    func validationSuccessful() {
        saveAddressDetails()
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)]) {
        print("Validation failed")
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subFields.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = self.subFields[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: AddressFieldCell.identifier) as! AddressFieldCell
        guard let type = field.typeEnum, type == .textBox,
            let responseKey = field.responseKey else {
                return UITableViewCell()
        }
        cell.field = field
        cell.onValueChanged = self.onCellValueChanged;
        cell.titleLabel.text = self.fieldTitle( field )
        cell.valueField.placeholder = self.fieldTitle( field )
		if let responseKey = field.responseKey, let value = currentAddress.valueFor(responseKey: responseKey) {
			cell.valueField.text = value as? String
		}
        registerCellForValidation(cell, responseKey: responseKey)
        updateCellInteractions(cell, responseKey: responseKey)
        return cell
    }
    
    private func registerCellForValidation(_ cell: AddressFieldCell, responseKey: String)  {
        guard let suffix = responseKey.components(separatedBy: ".").last else {
            return
        }
        
        switch suffix {
        case "street":
            formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [])
        case "addressDetail1":
            formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules:[])
        case "addressDetail2":
            formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [])
        case "city":
            formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules:[RequiredRule()])
        case "state":
            formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
        case "zip":
            formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [ZipCodeRule()])
        case "country":
            formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
        default:()
        }
    }
    
    private func updateCellInteractions(_ cell: AddressFieldCell, responseKey: String) {
        guard let suffix = responseKey.components(separatedBy: ".").last else {
            return
        }
        
        if( ["state", "country"].contains(suffix) ) {
            cell.valueField.isUserInteractionEnabled = false
        } else {
            cell.valueField.isUserInteractionEnabled = true
            
        }
        
        if( suffix == "zip") {
            cell.valueField.keyboardType = .numberPad
        } else {
            cell.valueField.keyboardType = .default
        }
        
    }

    // FIXME: code is identical to fieldPlaceHolder
    private func fieldTitle(_ field: Field) -> String {
        guard let suffix = field.responseKey?.components(separatedBy: ".").last else {
            return ""
        }
        // accidentDetails.location is set as value instead of code
        // setting lowercased value as temp fix
        let scenario = (claim?.value(forResponseKey: "accidentDetails.location") ?? "").lowercased()
        let placeholder = field.placeHolder ?? ""
        
		if suffix == "addressDetail1" {
			if scenario == "highway" {
				return NSLocalizedString("accidentdetails.address.milemarker", comment: "")
			} else {
				return NSLocalizedString("accidentdetails.address.crossstreetname", comment: "")
			}
		}
        if suffix == "addressDetail2" {
			return NSLocalizedString("accidentdetails.address.landmark", comment: "")
        }
        
        return placeholder
        
    }

    private func onCellValueChanged(_ cell: AddressFieldCell) {
        if let value = cell.valueField.text {
			self.claim?.setValue(value, displayValue: nil, forResponseKey: cell.responseKey)
            self.currentAddress.update(value: value, forResponseKey: cell.responseKey)
            
            cell.errorLabel.text = ""
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AddressFieldCell

        if let suffix = cell.responseKey.components(separatedBy: ".").last {
            switch suffix {
            case "state":
                self.performSegue(withIdentifier: "showStatesSegue", sender: cell)
            case "country":
                self.performSegue(withIdentifier: "showCountryPickSegue", sender: cell)
                
            default:()

            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableFooterView.identifier) as! TableFooterView
        footerCell.delegate = self
        footerCell.firstButtonText = NSLocalizedString("footer.cancel", comment: "Cancel")
        footerCell.nextButtonText = NSLocalizedString("footer.save", comment: "Save")
        footerCell.nextButton.isEnabled = true 
        return footerCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as? AddressFieldCell
        if segue.identifier == "showStatesSegue" {
            let vc  = segue.destination as! StatePickerVC
                vc.callback = { (value) in
                cell?.valueField.text = value
                    self.currentAddress.update(value: value, forResponseKey: (cell?.responseKey)!)

            }
        } else if segue.identifier == "showCountryPickSegue" {
            let vc  = segue.destination as! CountryPickVC
            vc.callback = { (value) in
                cell?.valueField.text = value
                self.currentAddress.update(value: value, forResponseKey: (cell?.responseKey)!)
                
            }
        }

    }
    
    /// Register the Error validation rules

    public func configureCell(cell: AddressFieldCell, responseKey: String)  {
        if let suffix = responseKey.components(separatedBy: ".").last {
            switch suffix {
            case "street":
                formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [])
            case "addressDetail1":
                formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules:[])
            case "addressDetail2":
                formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [])
            case "city":
                formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules:[])
            case "state":
                formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
                cell.valueField.isUserInteractionEnabled = false
            case "zip":
                formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [ZipCodeRule()])
            case "country":
                formValidator.registerField(cell.valueField, errorLabel: cell.errorLabel, rules: [RequiredRule()])
                cell.valueField.isUserInteractionEnabled = false

            default:
                return
            }
        }
        return 
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return defaultFooterHeight
    }
    
    // Handle mileMarker for based Accident Location
    func updatePlaceHolders() {
        guard let addressDetails2: Field =  self.addressFieldFromQuestionnaire?.subFields?.filter({($0 as! Field).responseKey == "accidentDetails.address.addressDetail2" }).first as? Field else {
            return
        }
        if addressDetails2.filterForLocationSelection(responsKey:"accidentDetails.location") == "highway" {
            addressDetails2.placeHolder = "Mile Marker"
            self.subFields.insert(addressDetails2, at: self.subFields.count-1)
        }else{
            addressDetails2.placeHolder = "Land Mark"
            self.subFields.insert(addressDetails2, at: self.subFields.count-1)
        }
    }
    
    func showConfirmAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("alert.title", comment: ""), message: NSLocalizedString("exit.withoutsavingaddress", comment: ""), preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: NSLocalizedString("alert.yes", comment: ""), style: .default) { (action) in
            alertController.removeFromParentViewController()
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(yesAction)
        let noAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("alert.no", comment: ""), style: .cancel, handler: { (UIAlertAction)in
            alertController.removeFromParentViewController()
        })
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension AddressFormVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}

extension AddressFormVC: FooterDelegate {
    
    func didTouchLeftButton() {
		showConfirmAlert()
    }
    
    func didTouchRightButton() {
        formValidator.validate(self)
}

}
