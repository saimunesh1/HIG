//
//  EditBankAccountViewController.swift
//  The General
//
//  Created by Leif Harrison on 12/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class EditBankAccountViewController: UITableViewController {

    @IBOutlet weak var labelField: UITextField!
    @IBOutlet weak var defaultMethodControl: YesNoSegmentControl!
    @IBOutlet weak var deleteButton: UIButton!
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

        defaultMethodControl.value = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let paymentMethod = self.paymentMethod {
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

    private func dismiss() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }

    private func populateRequest() -> UpdateBankAccountRequest? {
        guard let policyNumber = SessionManager.policyNumber, let accountId =  paymentMethod?.id else {
            return nil
        }

        let label = labelField.text
        let preferred = defaultMethodControl.value

        return UpdateBankAccountRequest(policyNumber: policyNumber, id: accountId, label: label, preferred: preferred)
    }

    private func saveChanges() {
        if let request = self.populateRequest() {
            let manager = ApplicationContext.shared.paymentsManager
            manager.updateBankAccount(request: request) { [weak self] (innerClosure) in
                do {
                    try innerClosure()
                    self?.dismiss()
                }
                catch {
                    self?.alert(NSLocalizedString("error.unknown.title", comment: ""), message: NSLocalizedString("error.unknown.message", comment: ""))
                }
            }
        }
    }

    private func deletePaymentMethod() {
        let manager = ApplicationContext.shared.paymentsManager
        if let paymentMethod = paymentMethod {
            let request = DeleteBankAccountRequest(policyNumber: SessionManager.policyNumber ?? "", bankAccountId: paymentMethod.id, isForceDelete: false)
            manager.deleteBankAccount(request: request) { [weak self] (innerClosure) in
                do {
                    try innerClosure()
                    self?.dismiss()
                }
                catch {
                    self?.alert(NSLocalizedString("error.unknown.title", comment: ""), message: NSLocalizedString("error.unknown.message", comment: ""))
                }
            }
        }
    }

}

//==============================================================================
// MARK: - UITextFieldDelegate
//==============================================================================

extension EditBankAccountViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == labelField {
            textField.resignFirstResponder()
        }

        return true
    }
}
