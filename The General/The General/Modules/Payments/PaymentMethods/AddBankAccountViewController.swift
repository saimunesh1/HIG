//
//  AddBankAccountViewController.swift.swift
//  The General
//
//  Created by Leif Harrison on 11/22/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AddBankAccountViewController: UITableViewController {

    @IBOutlet weak var routingNumberField: UITextField!
    @IBOutlet weak var routingNumberErrorLabel: UILabel!
    @IBOutlet weak var accountNumberField: UITextField!
    @IBOutlet weak var accountNumberErrorLabel: UILabel!
    @IBOutlet weak var labelField: UITextField!
    @IBOutlet weak var defaultMethodControl: YesNoSegmentControl!
    @IBOutlet weak var futureUseControl: YesNoSegmentControl!
    @IBOutlet weak var doneButton: UIButton!

    var dueDetails: PaymentsGetDueDetailsResponse? // TODO: Only using this for now to pass through Billing Address

    let formValidator = FormErrorValidator()

    var showSaveControl: Bool = false
    var showCardLabel: Bool = false
    var showDefaultControl: Bool = true

    enum TableSections: Int {
        case accountDetails
        case preferences
    }
    enum PreferencesRows: Int {
        case divider
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

        routingNumberField.attributedPlaceholder = Helper.requiredAttributedText(text: routingNumberField.placeholder ?? "")
        accountNumberField.attributedPlaceholder = Helper.requiredAttributedText(text: accountNumberField.placeholder ?? "")

        formValidator.styleTransformers(success: { (validationRule) -> Void in
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
        }, error:{ (validationError) -> Void in
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        })

        formValidator.registerField(routingNumberField, errorLabel: routingNumberErrorLabel, rules: [RequiredRule()])
        formValidator.registerField(accountNumberField, errorLabel: accountNumberErrorLabel, rules: [RequiredRule()])

        defaultMethodControl.value = false
        futureUseControl.value = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        defaultMethodControl.value = false
        futureUseControl.value = !showSaveControl
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func savePaymentSwitchChanged(_ sender: YesNoSegmentControl) {
        tableView.beginUpdates()
        
        showCardLabel = sender.value
        
        tableView.reloadData()
        tableView.endUpdates()
    }
    
    @IBAction func done(_ sender: UIButton) {
        
        var dismissView: ()->() = { [weak self] in
            if let navController = self?.navigationController {
                navController.popViewController(animated: true)
            }
        }
        
        // Validate entry fields
        formValidator.validate( { errors in
            if errors.count > 0 {
                print("Errors: \(errors)")
                return
            }
            else {
                // Save for temporary use
                if self.showSaveControl && !self.futureUseControl.value {
                    if let paymentSession = ApplicationContext.shared.paymentsManager.activeMakePaymentSession,
                        let paymentMethod = self.buildPaymentMethod() {
                        paymentSession.temporaryPaymentMethods.append(paymentMethod)
                        
                        dismissView()
                    }
                }
                // Save to account
                else {
                    LoadingView.show(inView: self.view, type: .hud, animated: true)
                    
                    if let request = self.populateRequest() {
                        let manager = ApplicationContext.shared.paymentsManager
                        manager.addBankAccount(request: request) { [weak self] (innerClosure) in
                            guard let weakSelf = self else { return }

                            defer {
                                LoadingView.hide(inView: weakSelf.view, animated: true)
                            }
                            
                            do {
                                try innerClosure()

                                dismissView()
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

    private func populateRequest() -> AddBankAccountRequest? {
        guard let routingNumber = routingNumberField.text, let accountNumber = accountNumberField.text else {
            return nil
        }

        let policyNumber = SessionManager.policyNumber ?? ""
        let preferred = defaultMethodControl.value
        return AddBankAccountRequest(policyNumber: policyNumber, routingNumber: routingNumber, accountNumber: accountNumber, saveForFuture: true, label: labelField.text, preferred: preferred)
    }
    
    private func buildPaymentMethod() -> PaymentMethodResponse? {
        guard let routingNumber = routingNumberField.text, let accountNumber = accountNumberField.text else {
            return nil
        }
        
        return PaymentMethodResponse(
            type: .bankAccount,
            id: 0,
            last4Digits: String(accountNumber.suffix(4)),
            label: nil,
            preferred: false,
            month: nil,
            year: nil,
            firstName: nil,
            lastName: nil,
            street: nil,
            city: nil,
            state: nil,
            zip: nil,
            routingNumber: routingNumber,
            saveForLater: false,
            accountNumber: accountNumber
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
            if section == .preferences && row == .label && !showCardLabel {
                return 0
            }
            if section == .preferences && row == .defaultMethod && !showDefaultControl {
                return 0
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

}

//==============================================================================
// MARK: - UITextFieldDelegate
//==============================================================================

extension AddBankAccountViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == routingNumberField {
            accountNumberField.becomeFirstResponder()
        }
        else if textField == accountNumberField {
            labelField.becomeFirstResponder()
        }
        else if textField == labelField {
            textField.resignFirstResponder()
        }

        return true
    }

}
