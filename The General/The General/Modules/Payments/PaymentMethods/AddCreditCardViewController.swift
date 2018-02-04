//
//  AddCreditCardViewController.swift
//  The General
//
//  Created by Leif Harrison on 11/22/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AddCreditCardViewController: UITableViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var cardNumberErrorLabel: UILabel!
    @IBOutlet weak var scanCardButton: UIButton!
    @IBOutlet weak var expirationDateField: UITextField!
    @IBOutlet weak var expirationErrorLabel: UILabel!
    @IBOutlet weak var addressControl: YesNoSegmentControl!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var addressErrorLabel: UILabel!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var cityErrorLabel: UILabel!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var stateErrorLabel: UILabel!
    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var zipErrorLabel: UILabel!
    @IBOutlet weak var labelField: UITextField!
    @IBOutlet weak var defaultMethodControl: YesNoSegmentControl!
    @IBOutlet weak var futureUseControl: YesNoSegmentControl!
    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet var addressLabelBottomConstraint: NSLayoutConstraint!

    var dueDetails: PaymentsGetDueDetailsResponse? // TODO: Only using this for now to pass through Billing Address
    var statePickerController: StatePickerController?

    let formValidator = FormErrorValidator()

    var useBillingAddress: Bool = false
    var showSaveControl: Bool = false
    var showDefaultControl: Bool = true

    enum TableSections: Int {
        case cardDetails
        case addressLabel
        case addressFields
        case preferences
    }
    
    enum PreferencesRows: Int {
        case title
        case saveMethod
        case label
        case defaultMethod
    }

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        view.hideKeyboardWhenTapped = true

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        tableView.separatorColor = UIColor.tgGray

        scanCardButton.isHidden = !CardIOUtilities.canReadCardWithCamera()
        scanCardButton.tintColor = .tgGreen

        firstNameField.attributedPlaceholder = Helper.requiredAttributedText(text: firstNameField.placeholder ?? "")
        lastNameField.attributedPlaceholder = Helper.requiredAttributedText(text: lastNameField.placeholder ?? "")
        cardNumberField.attributedPlaceholder = Helper.requiredAttributedText(text: cardNumberField.placeholder ?? "")
        expirationDateField.attributedPlaceholder = Helper.requiredAttributedText(text: expirationDateField.placeholder ?? "")
        addressField.attributedPlaceholder = Helper.requiredAttributedText(text: addressField.placeholder ?? "")
        cityField.attributedPlaceholder = Helper.requiredAttributedText(text: cityField.placeholder ?? "")
        stateField.attributedPlaceholder = Helper.requiredAttributedText(text: stateField.placeholder ?? "")
        zipField.attributedPlaceholder = Helper.requiredAttributedText(text: zipField.placeholder ?? "")

        statePickerController = StatePickerController(textField: stateField)

        formValidator.styleTransformers(success: { (validationRule) -> Void in
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
        }, error:{ (validationError) -> Void in
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        })

        formValidator.registerField(firstNameField, errorLabel: firstNameErrorLabel, rules: [RequiredRule()])
        formValidator.registerField(lastNameField, errorLabel: lastNameErrorLabel, rules: [RequiredRule()])
        formValidator.registerField(cardNumberField, errorLabel: cardNumberErrorLabel, rules: [RequiredRule()])
        formValidator.registerField(expirationDateField, errorLabel: expirationErrorLabel, rules: [ExpirationDateRule()])

        CardIOUtilities.preload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addressControl.value = false
        defaultMethodControl.value = false
        futureUseControl.value = !showSaveControl

        addressSegmentSelected(addressControl)

        if let details = self.dueDetails {
            addressLabel.text = "\(details.billingStreet ?? "")\n\(details.billingCity ?? ""), \(details.billingState ?? "") \(details.billingZip ?? "")"
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func saveForFutureUseChanged(_ sender: Any) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    @IBAction func scanCardNumber(_ sender: UIButton) {

        if let scanVC = storyboard?.instantiateViewController(withIdentifier: "ScanCreditCardViewController") as? ScanCreditCardViewController {
            scanVC.delegate = self
            scanVC.modalPresentationStyle = .overFullScreen
            present(scanVC, animated: true, completion: nil)
        }

    }

    @IBAction func addressSegmentSelected(_ sender: YesNoSegmentControl) {
        useBillingAddress = sender.value

        if useBillingAddress {
            formValidator.unregisterField(addressField)
            formValidator.unregisterField(cityField)
            formValidator.unregisterField(stateField)
            formValidator.unregisterField(zipField)
        }
        else {
            formValidator.registerField(addressField, errorLabel: addressErrorLabel, rules: [RequiredRule()])
            formValidator.registerField(cityField, errorLabel: cityErrorLabel, rules: [RequiredRule()])
            formValidator.registerField(stateField, errorLabel: stateErrorLabel, rules: [RequiredRule()])
            formValidator.registerField(zipField, errorLabel: zipErrorLabel, rules: [RequiredRule()])
        }
        tableView.reloadSections([TableSections.addressLabel.rawValue, TableSections.addressFields.rawValue], with: .fade)
    }

    @IBAction func done(_ sender: UIButton) {
        // Validate entry fields
        formValidator.validate( { errors in
            if errors.count > 0 {
                print("Errors: \(errors)")
                return
            }
            else {
                LoadingView.show(inView: self.view, type: .hud, animated: true)

                // Save for temporary use
                if self.showSaveControl && !self.futureUseControl.value {
                    if let paymentSession = ApplicationContext.shared.paymentsManager.activeMakePaymentSession,
                        let request = self.populateTemporaryRequest() {
                        ApplicationContext.shared.paymentsManager.generateToken(request: request) { [weak self] (innerClosure) in
                            guard let weakSelf = self else { return }
                            
                            defer {
                                LoadingView.hide(inView: weakSelf.view, animated: true)
                            }
                            
                            do {
                                let token = try innerClosure()
                                if let paymentMethod = self?.buildPaymentMethod(fromRequest: request, token: token) {
                                    paymentSession.temporaryPaymentMethods.append(paymentMethod)
                                }
                                
                                // Dismiss view
                                if let navController = weakSelf.navigationController {
                                    navController.popViewController(animated: true)
                                }
                            }
                            catch {
                                let alert = UIAlertController(title: NSLocalizedString("error.unknown.title", comment: ""), message: NSLocalizedString("error.unknown.message", comment: ""), preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("error.unknown.actionTitle", comment: ""), style: .default, handler: nil))
                                weakSelf.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else {
                        LoadingView.hide(inView: self.view, animated: true)
                    }
                }
                // Save to account
                else {
                    if let request = self.populateRequest() {
                        let manager = ApplicationContext.shared.paymentsManager
                        manager.addCreditCard(request: request) { [weak self] (innerClosure) in
                            guard let weakSelf = self else { return }
                            
                            defer {
                                LoadingView.hide(inView: weakSelf.view, animated: true)
                            }

                            do {
                                try innerClosure()

                                // Dismiss view
                                if let navController = weakSelf.navigationController {
                                    navController.popViewController(animated: true)
                                }
                            }
                            catch {
                                let alert = UIAlertController(title: NSLocalizedString("error.unknown.title", comment: ""), message: NSLocalizedString("error.unknown.message", comment: ""), preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("error.unknown.actionTitle", comment: ""), style: .default, handler: nil))
                                weakSelf.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else {
                        LoadingView.hide(inView: self.view, animated: true)
                    }
                }
            }
        })
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func populateRequest() -> AddCardRequest? {
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let cardNumber = cardNumberField.text else {
            return nil
        }

        let formatter = DateFormatter.monthYear
        guard let value = expirationDateField.text, let expirationDate = formatter.date(from: value) else {
            return nil
        }
        let expiration = Calendar.current.dateComponents([.month, .year], from: expirationDate)
        guard let month = expiration.month, let year = expiration.year else {
            return nil
        }

        var address: BillingAddress? = nil
        if addressControl.value {
            if let street = dueDetails?.billingStreet, let city = dueDetails?.billingCity, let state = dueDetails?.billingState, let zip = dueDetails?.billingZip?.prefix(5) {
                address = BillingAddress(street: street, city: city, state: state, zip: String(zip))
            }
        }
        else {
            if let street = addressField.text, let city = cityField.text, let state = stateField.text, let zip = zipField.text {
                address = BillingAddress(street: street, city: city, state: state, zip: zip)
            }
        }

        let policyNumber = SessionManager.policyNumber ?? ""
        let preferred = defaultMethodControl.value
        return AddCardRequest(policyNumber: policyNumber, firstName: firstName, lastName: lastName, cardNumber: cardNumber, month: month, year: year, address: address, saveForFuture: true, label: labelField.text, preferred: preferred)
    }
    
    private func populateTemporaryRequest() -> GenerateTokenRequest? {
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let cardNumber = cardNumberField.text else {
            return nil
        }
        
        let formatter = DateFormatter.monthYear
        guard let value = expirationDateField.text, let expirationDate = formatter.date(from: value) else {
            return nil
        }
        let expiration = Calendar.current.dateComponents([.month, .year], from: expirationDate)
        guard let month = expiration.month, let year = expiration.year else {
            return nil
        }
        
        let street: String
        let city: String
        let state: String
        let zip: String
        if self.addressControl.value {
            street = self.dueDetails?.billingStreet ?? ""
            city = self.dueDetails?.billingCity ?? ""
            state = self.dueDetails?.billingState ?? ""
            zip = String(self.dueDetails?.billingZip?.prefix(while: { $0 != "-" }) ?? "") 
        }
        else {
            street = self.addressField.text ?? ""
            city = self.cityField.text ?? ""
            state = self.stateField.text ?? ""
            zip = self.zipField.text ?? ""
        }
        
        let policyNumber = SessionManager.policyNumber ?? ""
        return GenerateTokenRequest(
            policyNumber: policyNumber,
            cardNumber: cardNumber,
            month: UInt(month),
            year: UInt(year),
            firstName: firstName,
            lastName: lastName,
            street: street,
            city: city,
            state: state,
            zip: zip
        )
    }
    
    private func buildPaymentMethod(fromRequest request: GenerateTokenRequest, token: String) -> PaymentMethodResponse? {
        return PaymentMethodResponse(
            type: .card,
            id: UInt(token) ?? 0,
            last4Digits: String(request.cardNumber.suffix(4)),
            label: nil,
            preferred: false,
            month: request.month,
            year: request.year,
            firstName: request.firstName,
            lastName: request.lastName,
            street: request.street,
            city: request.city,
            state: request.state,
            zip: request.zip,
            routingNumber: nil,
            saveForLater: false,
            accountNumber: nil
        )
    }

    //--------------------------------------------------------------------------
    // MARK: - UITableViewDelegate
    //--------------------------------------------------------------------------

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let section = TableSections(rawValue: indexPath.section), let row = PreferencesRows(rawValue: indexPath.row) {
            if section == .preferences && row == .saveMethod && !showSaveControl {
                return 0
            }
            if section == .preferences && row == .defaultMethod && !showDefaultControl {
                return 0
            }
            if section == .preferences && row == .label && !futureUseControl.value {
                return 0
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = TableSections(rawValue: section) {
            if section == .addressLabel && !useBillingAddress {
                return 0
            }
            if section == .addressFields && useBillingAddress {
                return 0
            }
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

}

//==============================================================================
// MARK: - UITextFieldDelegate
//==============================================================================

extension AddCreditCardViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        }
        else if textField == lastNameField {
            cardNumberField.becomeFirstResponder()
        }
        else if textField == cardNumberField {
            expirationDateField.becomeFirstResponder()
        }
        else if textField == expirationDateField && !useBillingAddress {
            addressField.becomeFirstResponder()
        }
        else if textField == expirationDateField && useBillingAddress {
            labelField.becomeFirstResponder()
        }
        else if textField == addressField {
            cityField.becomeFirstResponder()
        }
        else if textField == cityField {
            stateField.becomeFirstResponder()
        }
        else if textField == stateField {
            zipField.becomeFirstResponder()
        }
        else if textField == zipField {
            labelField.becomeFirstResponder()
        }
        else if textField == labelField {
            textField.resignFirstResponder()
        }

        return true
    }
    
}

extension AddCreditCardViewController: ScanCreditCardViewControllerDelegate {

    func scanCreditCardViewController(_ viewController: ScanCreditCardViewController, didScanCard cardInfo: CardIOCreditCardInfo) {
        cardNumberField.text = cardInfo.cardNumber
        if (cardInfo.expiryMonth > 0) && (cardInfo.expiryYear > 0) {
            expirationDateField.text = "\(cardInfo.expiryMonth) / \(cardInfo.expiryYear)"
        }
    }
    
}
