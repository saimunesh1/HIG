//
//  ProfileEditTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 27/12/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ProfileEditTableVC: UITableViewController, UIValidationDelegate {

    @IBOutlet weak var addressOneTextField: UITextField!
    @IBOutlet weak var addressTwoTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var primaryPhoneTextField: UITextField!
    @IBOutlet weak var secondaryPhoneTextField: UITextField!
    @IBOutlet weak var policyEmailTextField: UITextField!
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var lblAddressOneError: UILabel!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var lblAddressTwoError: UILabel!
    @IBOutlet weak var lblStateZipError: UILabel!
    @IBOutlet weak var lblPrimaryPhError: UILabel!
    @IBOutlet weak var lblSecondaryPhError: UILabel!
    @IBOutlet weak var lblPolicyEmailError: UILabel!
    @IBOutlet weak var lblLoginEmailError: UILabel!
    
    let formValidator = FormErrorValidator()
    var statePickerController: StatePickerController?
    
    var addressModified: Bool = false
    var phoneNumberModified: Bool = false
    var emailModified: Bool = false
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        registerNibs()
        setUpKeyBoardTypes()
        setInitialValues()
        textFieldChangeListeners()
        registerFormValidator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    //MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddressVerificationSegue" {
            let address = sender as? AddressRequest
            if let cnt = segue.destination as? ProfileEditAddressVerificationVC {
                cnt.addressRequest = address
            }
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    
    // MARK: - Private Helpers
    private func registerNibs() {
        tableView.register(TableHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableHeaderView.identifier)
    }
    
    private func registerFormValidator() {
        formValidator.registerField(primaryPhoneTextField, errorLabel: lblPrimaryPhError, rules: [ExactLengthRule(length: 10)])
        formValidator.registerField(secondaryPhoneTextField, errorLabel: lblSecondaryPhError, rules: [ExactLengthRule(length: 10)])
    }
    
    private func setUpKeyBoardTypes() {
        zipTextField.keyboardType = .numberPad
        primaryPhoneTextField.keyboardType = .numberPad
        secondaryPhoneTextField.keyboardType = .numberPad
        statePickerController = StatePickerController(textField: stateTextField)
    }
    
    private func setInitialValues() {
        
        if let addressInfo = ApplicationContext.shared.profileManager.addressInfo {
            addressOneTextField.text = addressInfo.streetAddress
            cityTextField.text = addressInfo.city
            stateTextField.text = addressInfo.state
            zipTextField.text = addressInfo.zip
        }
        
        if let profileResp = ApplicationContext.shared.profileManager.profileInfo {
            loginEmailTextField.text = profileResp.loginEmailAddress
            policyEmailTextField.text = profileResp.policyEmailAddress
        }
        
        if let phoneNum = ApplicationContext.shared.phoneOptionsManager.phonesInfo?.phoneOpts {
            if let primary = phoneNum.first(where: { $0.isPrimary }) {
                primaryPhoneTextField.text = "\(primary.phoneAreaOriginal)\(primary.phoneNumberOriginal)"
            }
            if let sec = phoneNum.first(where: { !$0.isPrimary }) {
                secondaryPhoneTextField.text = "\(sec.phoneAreaOriginal)\(sec.phoneNumberOriginal)"
            }
        }
    }
    
    private func textFieldChangeListeners() {
        addressOneTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
        addressTwoTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
        stateTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
        cityTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
        zipTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
        primaryPhoneTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
        secondaryPhoneTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
        loginEmailTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
        policyEmailTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
    }
    
    // This dispatch group will run updates of phone number and email if modified and then call the update address.
    private func performUpdates() {
        let group = DispatchGroup()
        LoadingView.show()
        if emailModified {
            // Update Email Info
            group.enter()
            let emailBody = [
                "loginEmailAddress": loginEmailTextField.text ?? "",
                "policyEmailAddress": policyEmailTextField.text ?? ""
            ]
            ApplicationContext.shared.profileManager.updateEmail(with: emailBody, completion: { (_) in
                group.leave()
            })
        }
        if phoneNumberModified {
            // Phone number update
            group.enter()
            guard let primaryPhone = ApplicationContext.shared.phoneOptionsManager.phonesInfo?.phoneOpts.first(where: { $0.isPrimary }), let secondaryPhone = ApplicationContext.shared.phoneOptionsManager.phonesInfo?.phoneOpts.first(where: { !$0.isPrimary }) else {
                group.leave()
                LoadingView.hide()
                return
            }
            
            guard let newPrimary = primaryPhoneTextField.text, let newSecondary = secondaryPhoneTextField.text else {
                group.leave()
                return
            }
            let indexArea = newPrimary.index(newPrimary.startIndex, offsetBy: 2)
            let indexPhone = newPrimary.index(newPrimary.startIndex, offsetBy: 3)
            
            let newPrimaryAreaCode = newPrimary[...indexArea]
            let newPrimaryPhone = newPrimary[indexPhone...]
            let newSecondaryAreaCode = newSecondary[...indexArea]
            let newSecondaryPhone = newSecondary[indexPhone...]
            
            let primaryPhoneRequest = buildPhoneRequest(from: primaryPhone, area: String(newPrimaryAreaCode), phone: String(newPrimaryPhone))
            let secondaryPhoneRequest = buildPhoneRequest(from: secondaryPhone, area: String(newSecondaryAreaCode), phone: String(newSecondaryPhone))
            
            ApplicationContext.shared.phoneOptionsManager.updatePhones(with: [primaryPhoneRequest, secondaryPhoneRequest], completion: { (_) in
                group.leave()
            })
        }
        group.notify(queue: .main, work: DispatchWorkItem(block: { [weak self] in
            guard let sSelf = self else { return }
            LoadingView.hide()
            sSelf.updateAddressIfNeeded()
        }))
    }
    
    private func buildPhoneRequest(from response: PhoneOptionsResponse, area: String, phone: String) -> PhoneOptionsRequest {
        return PhoneOptionsRequest(fName: response.fName,
                                   lName: response.lName,
                                   middleInitial: response.middleInitial,
                                   driverNo: response.driverNo,
                                   phoneAreaOriginal: response.phoneAreaOriginal,
                                   phoneNumberOriginal: response.phoneNumberOriginal,
                                   phoneArea: area,
                                   phoneNumber: phone,
                                   primaryFlag: response.primaryFlag,
                                   preferenceOriginal: response.preferenceOriginal.rawValue,
                                   preferenceNew: response.preferenceOriginal.rawValue)
    }
    
    // Based on if address was edited an update address request is performed.
    private func updateAddressIfNeeded() {
        if addressModified {
            let addressRequest = AddressRequest(city: cityTextField.text ?? "",
                                                state: stateTextField.text ?? "",
                                                streetAddress: "\(addressOneTextField.text ?? "") \(addressTwoTextField.text ?? "")",
                                                zip: zipTextField.text ?? "")
            ApplicationContext.shared.profileManager.searchAddressDetails(with: addressRequest, completion: { [weak self] (innerClosure) in
                guard let sSelf = self else { return }
                if let response = try? innerClosure() {
                    // If only one address available update, else refine in address verification modal view
                    if response.singleAddress {
                        sSelf.updateAddress(with: addressRequest)
                    } else {
                        sSelf.performSegue(withIdentifier: "AddressVerificationSegue", sender: addressRequest)
                    }
                }
            })
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateAddress(with request: AddressRequest) {
        LoadingView.show()
        ApplicationContext.shared.profileManager.updateAddressDetails(with: request) { [weak self] (innerClosure) in
            guard let sSelf = self else { return }
            LoadingView.hide()
            if let response = try? innerClosure() {
                if response.success {
                    if let profileVC = sSelf.navigationController?.viewControllers.first(where: { $0 is ProfileTableVC }) as? ProfileTableVC {
                        sSelf.navigationController?.popToViewController(profileVC, animated: true)
                        profileVC.showSuccessBanner()
                    }
                }
            }
        }
    }
    
    
    // MARK: - Button Actions
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        formValidator.validate(self)
    }
    
    
    // MARK: - Validations
    func validationSuccessful() {
        performUpdates()
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)]) {
        print("Validation failed")
    }
}

extension ProfileEditTableVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case let x where (x == primaryPhoneTextField || x == secondaryPhoneTextField):
            phoneNumberModified = true
        case let x where (x == addressOneTextField || x == addressTwoTextField || x == cityTextField || x == stateTextField || x == zipTextField):
            addressModified = true
        case let x where (x == loginEmailTextField || x == policyEmailTextField):
            emailModified = true
        default: break
        }
    }
}
