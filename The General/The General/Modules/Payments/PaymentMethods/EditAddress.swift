//
//  EditAddressViewController.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 1/15/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct Address {
    
    enum Mode {
        case allFields
        case basicFields
    }
    
    var mode: Mode = .allFields
    
    let street: String?
    let line1: String?
    let line2: String?
    let city: String?
    let state: String?
    let country: String?
    let zip: String?
}

enum EditAddressError: Error {
    case noRootViewController
}

//--------------------------------------------------------------------------
// MARK: - Manager
//--------------------------------------------------------------------------
class EditAddress {
    
    
    //MARK: - Interface
    class func show(withExistingAddress address: Address?, finished: ((_ updatedAddress: Address?) -> ())?) throws {
        try EditAddress().present(withExistingAddress: address, finished: finished)
    }
    
    private func present(withExistingAddress address: Address?, finished: ((_ updatedAddress: Address?) -> ())?) throws {
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            throw EditAddressError.noRootViewController
        }
        
        self.complete = finished
        self.previousAddress = address
        
        let paymentsStoryboard = UIStoryboard(name: "Payments", bundle: nil)
        let editAddressNavigationController = paymentsStoryboard.instantiateViewController(withIdentifier: "Edit Address Navigation Controller") as! UINavigationController
        
        let editAddressViewController = editAddressNavigationController.viewControllers.first as! EditAddressViewController
        
        self.view = editAddressViewController
        self.view.manager = self
        
        rootViewController.present(editAddressNavigationController, animated: true)
    }
    
    
    //MARK: - View to Manager
    fileprivate func viewIsReady() {
        if let previousAddress = self.previousAddress {
            self.view.showAddress(previousAddress)
            
        } else {
            let emptyAddress = Address(mode: .basicFields, street: nil, line1: nil, line2: nil, city: nil, state: nil, country: nil, zip: nil)
            self.view.showAddress(emptyAddress)
        }
        
    }
    
    fileprivate func userChoseToCancel() {
        self.view.navigationController?.dismiss(animated: true, completion: nil)
        
        self.complete?(nil)
    }
    
    fileprivate func userChoseToSave(withAddress address: Address) {
        self.view.navigationController?.dismiss(animated: true, completion: nil)
        
        self.complete?(address)
    }
    
    
    //MARK: - Private
    private var previousAddress: Address?
    
    private var complete: ((_ updatedAddress: Address?)->())?
    
    private var view: EditAddressViewController!
}


//--------------------------------------------------------------------------
// MARK: - View Controller
//--------------------------------------------------------------------------
class EditAddressViewController: UITableViewController {
	
	let formValidator = FormErrorValidator()

    //Interface
    func showAddress(_ address: Address) {
        self.addressField.text = address.street
        self.unitField.text = address.line1
        self.line2Field.text = address.line2
        self.cityField.text = address.city
        self.stateLabel.text = address.state
        self.countryLabel.text = address.country
        self.zipField.text = address.zip
        
        
        var fieldsToShow: Set<Field>! //Order is determined by view, the following indicates whether it's shown or not.
        
        switch address.mode {
        case .allFields:
            fieldsToShow = [.street, .unit, .line2, .city, .state, .country, .zip]
            
        case .basicFields:
            fieldsToShow = [.street, .city, .state, .zip]
        }
        
        self.fieldsShowing = fieldsToShow
        self.tableView.reloadData()
    }
    
    
    //MARK: - Actions
    @IBAction func stateAction(_ sender: UIButton) {
        
        guard let stateViewController = fnolStoryboard.instantiateViewController(withIdentifier: "State View Controller") as? StatePickerVC else {
            return
        }
        
        stateViewController.callback = { [weak self] valueEntered in
            self?.stateLabel.text = valueEntered
        }
        
        self.navigationController?.pushViewController(stateViewController, animated: true)
    }
    
    @IBAction func countryAction(_ sender: UIButton) {
        
        guard let countryViewController = fnolStoryboard.instantiateViewController(withIdentifier: "Country View Controller") as? CountryPickVC else {
            return
        }
        
        countryViewController.callback = { [weak self] valueEntered in
            self?.countryLabel.text = valueEntered
        }
        
        self.navigationController?.pushViewController(countryViewController, animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        
        func cancel(strongSelf: EditAddressViewController) {
            strongSelf.manager.userChoseToCancel()
        }
        
        guard fieldsHaveBeenEdited else {
            cancel(strongSelf: self)
            return
        }
        
        let alert = UIAlertController(title: nil, message: NSLocalizedString("alert.message.cancel", comment: ""), preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: NSLocalizedString("alert.yes", comment: ""), style: .destructive) { [weak self] (action) in
            
            guard let strongSelf = self else {
                return
            }
            
            cancel(strongSelf: strongSelf)
        }
        
        let nevermindButton = UIAlertAction(title: NSLocalizedString("alert.nevermind", comment: ""), style: .default, handler: nil)
        
        alert.addAction(okButton)
        alert.addAction(nevermindButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: CustomButton) {
		formValidator.validate(self)
    }
    
    
    //MARK: - Table View
    var rowHeight: CGFloat = 45
    let kDoneRowHeight: CGFloat = 63
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellMapping.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let fieldsShowing = self.fieldsShowing else {
            return 0
        }
        
        let cellType = self.cellMapping[indexPath.row].type
        
        guard cellType != .done else {
            return kDoneRowHeight
        }
        
        return fieldsShowing.contains(cellType) ? rowHeight : 0
    }
    
    
    //MARK: - Private
    private enum Field {
        case street
        case unit
        case line2
        case city
        case state
        case country
        case zip
        case done
    }
    
    private var address: Address?
    
    private var fieldsShowing: Set<Field>? {
        didSet {
            self.view.layoutIfNeeded()
            
            let totalRowCount = self.fieldsShowing?.count ?? 0
            
            let kMaxRowHeight: CGFloat = 70
            
            let topHalfScreenHeight: CGFloat = self.view.bounds.height / 2
            
            self.rowHeight = min(topHalfScreenHeight / CGFloat(totalRowCount), kMaxRowHeight)
            
        }
    }
    private var mode: Address.Mode = .allFields
    
    fileprivate var manager: EditAddress! // Needs to be strong
    fileprivate lazy var fnolStoryboard = UIStoryboard(name: "FNOL", bundle: nil)
    
    private var fieldsHaveBeenEdited = false
    
    //MARK: Outlets
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var unitField: UITextField!
    @IBOutlet weak var line2Field: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var zipField: UITextField!
	@IBOutlet weak var zipFieldErrorLabel: UILabel!
	
    @IBOutlet weak var streetCell: UITableViewCell!
    @IBOutlet weak var unitCell: UITableViewCell!
    @IBOutlet weak var line2Cell: UITableViewCell!
    @IBOutlet weak var cityCell: UITableViewCell!
    @IBOutlet weak var stateCell: UITableViewCell!
    @IBOutlet weak var countryCell: UITableViewCell!
    @IBOutlet weak var zipCell: UITableViewCell!
    @IBOutlet weak var doneCell: UITableViewCell!
    
    lazy private var cellMapping: [(type: Field, cell: UITableViewCell)] = [
                                                    (.street, streetCell),
                                                    (.unit, unitCell),
                                                    (.line2, line2Cell),
                                                    (.city, cityCell),
                                                    (.state, stateCell),
                                                    (.country, countryCell),
                                                    (.zip, zipCell),
                                                    (.done, doneCell)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        manager.viewIsReady()
		zipFieldErrorLabel.text = ""
		formValidator.registerField(zipField, errorLabel: zipFieldErrorLabel, rules: [ZipCodeRule()])

		// Field validation
		formValidator.styleTransformers(success: { (validationRule) -> Void in
			// clear error label
			validationRule.errorLabel?.isHidden = true
			validationRule.errorLabel?.text = ""
		}, error:{ (validationError) -> Void in
			validationError.errorLabel?.isHidden = false
			validationError.errorLabel?.text = validationError.errorMessage
		})
    }
    
    private func setupView() {
        self.tableView.tableFooterView = UIView()
    }
}

extension EditAddressViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        fieldsHaveBeenEdited = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension EditAddressViewController: UIValidationDelegate {
	
	///Error handling Validation Successful
	///
	func validationSuccessful() {
		let address = Address(mode:self.address?.mode ?? .allFields, street: self.addressField.text, line1: unitField.text, line2: line2Field.text, city: cityField.text, state: stateLabel.text, country: countryLabel.text, zip: zipField.text)
		manager.userChoseToSave(withAddress: address)
	}
	
	///Error handling Validation Unsuccessful
	///
	func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)]) {
	}

}
