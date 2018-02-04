//
//  PaymentMethodsDeclinedViewController.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 12/14/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PaymentDeclinedCell: UITableViewCell {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
}

class PaymentsDeclinedViewController: UITableViewController {
    // MARK: - configuration to be set by host view controller
    weak var delegate: MakePaymentViewControllerDelegate?
    
    var failedPayments: [MakePaymentEntry] = []
    var successfulPayments: [MakePaymentEntry] = []
    var paymentSession: MakePaymentSession?
    
    private var alteredPaymentMethodTableIndices = Set<Int>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    
    // MARK: - button actions
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    @IBAction func didTouchCancel(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        self.delegate?.makePaymentsFinished(successfulPayments: successfulPayments, failedPayments: failedPayments)
    }
    
    @IBAction func didTouchSubmit(_ sender: Any) {
        if allPaymentMethodsChanged() {
            self.reprocessPayment()
            
        } else {
            let promptTitle = NSLocalizedString("Use the same card to pay the balance?", comment: "")
            let okButton = NSLocalizedString("Proceed", comment: "")
            
            self.prompt(promptTitle, message: "", ok: okButton) {
                self.reprocessPayment()
            }
        }
    }
    
    
    // MARK: - reprocess payment
    func allPaymentMethodsChanged() -> Bool {
        if alteredPaymentMethodTableIndices.count >= failedPayments.count {
            return true
        }
        
        return false
    }
    
    func reprocessPayment() {
        let loadingMessage = NSLocalizedString("payments.ui.processing", comment: "")
        LoadingView.show(inView: self.view, type: .hud, displayText: loadingMessage, animated: true)
        
        // prepare failed payments to process
        paymentSession?.paymentEntries = self.failedPayments
        
        do {
            try ApplicationContext.shared.paymentsManager.submitImmediatePayment(submitPaymentComplete)
        }
        catch SubmitPaymentErrorType.noPaymentMethods {
            submitPaymentFail(NSLocalizedString("No Payment Method Selected", comment: ""), message: NSLocalizedString("Please select a payment method and try again.", comment: ""))
        }
        catch {
            submitPaymentFail(NSLocalizedString("Error", comment: ""), message: error.localizedDescription)
        }
        
    }
    
    private func submitPaymentComplete(newSuccessfulPayments: [MakePaymentEntry], failedPayments: [MakePaymentEntry]) {
        
        // appending successful payments to array to keep track of all payment methods processed
        self.successfulPayments.append(contentsOf: newSuccessfulPayments)
        
        // reseting failed payments to update UI
        self.failedPayments = failedPayments
        
        self.alteredPaymentMethodTableIndices.removeAll()
        
        if failedPayments.count > 0 {
            LoadingView.hide(inView: self.view, animated: true)
            self.showDeclinedPaymentAlert()
            self.tableView.reloadData()
        } else {
            LoadingView.showComplete(animated: true, inView: self.view) {
                self.navigationController?.popToRootViewController(animated: true)
                self.delegate?.makePaymentsFinished(successfulPayments: self.successfulPayments, failedPayments: failedPayments)
            }
        }
    }
    
    private func submitPaymentFail(_ title: String, message: String) {
        LoadingView.hide(inView: self.view, animated: true)
        self.alert(title, message: message)
    }
    
    func showDeclinedPaymentAlert() {
        let title = NSLocalizedString("Payment Declined", comment: "")
        let message = NSLocalizedString("Please select alternate payment methods and try again.", comment: "")
        
        self.alert(title, message: message)
    }
    
    
    // MARK: - select payment method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "payment-methods" {
            guard let paymentIndex = self.tableView.indexPathForSelectedRow else {
                return
            }
            
            let declinedPaymentEntry = self.failedPayments[paymentIndex.row]
            let paymentMethodsVc = segue.destination as! PaymentMethodsViewController
            
            paymentMethodsVc.paymentMode = .selectingForPayment
            paymentMethodsVc.paymentMethodSelectedHandler = { selectedPaymentMethod in
                if declinedPaymentEntry.paymentMethod! == selectedPaymentMethod {
                    return
                }
                
                declinedPaymentEntry.paymentMethod = selectedPaymentMethod
                self.alteredPaymentMethodTableIndices.insert(paymentIndex.row)
            }
        }
    }
    
}


// MARK: - UITableViewDelete, UITableVieWDataSource
extension PaymentsDeclinedViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return failedPayments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "payment-declined-cell") as! PaymentDeclinedCell
        let entry = failedPayments[indexPath.row]
        
        cell.amountLabel.text = PaymentFormatter.currency(for: entry.amount)
        cell.methodLabel.text = PaymentFormatter.accountLabel(for: entry.paymentMethod!)
        
        if alteredPaymentMethodTableIndices.contains(indexPath.row) {
            cell.methodLabel.textColor = UIColor.tgTextFontColor
            cell.messageLabel.isHidden = true
        } else {
            cell.methodLabel.textColor = UIColor.tgRed
            cell.messageLabel.isHidden = false
        }
        
        return cell
    }
}
