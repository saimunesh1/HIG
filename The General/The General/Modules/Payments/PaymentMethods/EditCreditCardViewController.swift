//
//  EditCreditCardViewController.swift
//  The General
//
//  Created by Leif Harrison on 12/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class EditCreditCardViewController: UITableViewController {

    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var expirationDateField: UITextField!
    @IBOutlet weak var expirationErrorLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var labelField: UITextField!
    @IBOutlet weak var defaultMethodControl: YesNoSegmentControl!
    @IBOutlet weak var doneButton: UIButton!

    let formValidator = FormErrorValidator()

    var paymentMethod: PaymentMethodResponse?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        view.hideKeyboardWhenTapped = true

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        tableView.separatorColor = UIColor.tgGray

        expirationDateField.attributedPlaceholder = Helper.requiredAttributedText(text: expirationDateField.placeholder ?? "")

        formValidator.styleTransformers(success: { (validationRule) -> Void in
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
        }, error:{ (validationError) -> Void in
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        })

        formValidator.registerField(expirationDateField, errorLabel: expirationErrorLabel, rules: [RequiredRule()])

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.refreshView()
    }
    
    fileprivate func refreshView() {
        
        if let paymentMethod = self.paymentMethod {
            cardNumberLabel.text = "XXXX XXXX XXXX " + paymentMethod.last4Digits
            if let month = paymentMethod.month, let year = paymentMethod.year {
                expirationDateField.text = "\(month)/\(year)"
            }
            addressLabel.text = "\(paymentMethod.street ?? "")\n\(paymentMethod.city ?? ""), \(paymentMethod.state ?? "") \(paymentMethod.zip ?? "")"
            labelField.text = paymentMethod.label
            defaultMethodControl.value = paymentMethod.preferred
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func deletePaymentMethod(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: NSLocalizedString("payments.alert.deletepaymentmethod", comment: ""), style: .default) { [weak self] (action) in
            self?.deletePaymentMethod()
        }
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: NSLocalizedString("alert.cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addressAction(_ sender: UIButton) {
        
        // Create address object from current payment method
        let existingAddress = Address(mode: .basicFields, street: paymentMethod?.street, line1: nil, line2: nil, city: paymentMethod?.city, state: paymentMethod?.state, country: nil, zip: paymentMethod?.zip)
        
        try? EditAddress.show(withExistingAddress: existingAddress) { [weak self] modifiedAddress in
            
            // Transfer address object back to payment method
            if let address = modifiedAddress, var paymentMethod = self?.paymentMethod, let street = address.street {
                var fullStreet: String = street
                if let line1 = address.line1, !line1.isEmpty {
                    fullStreet += " \(line1)"
                }
                if let line2 = address.line2, !line2.isEmpty {
                    fullStreet += " \(line2)"
                }
                paymentMethod.street = fullStreet
                paymentMethod.city = address.city
                paymentMethod.state = address.state
                paymentMethod.zip = address.zip
                
                self?.paymentMethod = paymentMethod
            }
        }
    }
    
    @IBAction func done(_ sender: UIButton) {
        // Validate entry fields
        formValidator.validate( { errors in
            if errors.count > 0 {
                print("Errors: \(errors)")
                return
            }
            else {
                saveChanges()
            }
        })
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func populateRequest() -> UpdateCardRequest? {

        guard let policyNumber = SessionManager.policyNumber, let cardId =  paymentMethod?.id else {
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

        let label = labelField.text
        let preferred = defaultMethodControl.value

        // Copy the rest from the PaymentMethodResponse
        let firstName = paymentMethod?.firstName
        let lastName = paymentMethod?.lastName
        let address = BillingAddress(street: paymentMethod?.street, city: paymentMethod?.city, state: paymentMethod?.state, zip: paymentMethod?.zip)

        return UpdateCardRequest(policyNumber: policyNumber, id: cardId, firstName: firstName, lastName: lastName, cardNumber: nil, month: month, year: year, address: address, label: label, preferred: preferred)
    }

    private func saveChanges() {
        // Save changes
        if let request = self.populateRequest() {
            let manager = ApplicationContext.shared.paymentsManager
            manager.updateCreditCard(request: request) { [weak self] (innerClosure) in
                guard let weakSelf = self else { return }

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
    }

    private func deletePaymentMethod() {
        let manager = ApplicationContext.shared.paymentsManager
        if let paymentMethod = paymentMethod {
            let request = DeleteCardRequest(policyNumber: SessionManager.policyNumber ?? "", cardId: paymentMethod.id, isForceDelete: false)
            manager.deleteCreditCard(request: request) { [weak self] (innerClosure) in
                guard let weakSelf = self else { return }

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
    }
}

//==============================================================================
// MARK: - UITextFieldDelegate
//==============================================================================

extension EditCreditCardViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == expirationDateField {
            labelField.becomeFirstResponder()
        }
        else if textField == labelField {
            textField.resignFirstResponder()
        }

        return true
    }

}
