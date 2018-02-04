//
//  MakePaymentViewController.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol MakePaymentViewControllerDelegate: class {
    func makePaymentsFinished(successfulPayments: [MakePaymentEntry], failedPayments: [MakePaymentEntry])
}

class MakePaymentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: MakePaymentViewControllerDelegate?
    let cellManager = MakePaymentCellManager()
    var paymentSession: MakePaymentSession?
    let dueDetails = ApplicationContext.shared.paymentsManager.dueDetails
    private let cellHeight: CGFloat = 110.0
    private let inset: CGFloat = 6.0
    private let itemsPerRow: CGFloat = 2
    private var sectionInsets: UIEdgeInsets!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(_: )), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(_: )), name: Notification.Name.UIKeyboardWillShow, object: nil)
        self.startPaymentSession()
        
        if let details = self.dueDetails, details.autoDebitEnabled {
            self.showSlidableAlert(withTitle: NSLocalizedString("payments.autopay.paymentalert.title", comment: ""), message: NSLocalizedString("payments.autopay.paymentalert.message", comment: ""), type: SlidableAlertType.attention, longDelay: true)
            
            let forcedTopContraint = self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
            forcedTopContraint.isActive = true
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0) {
            self.tableView.reloadData()
        }
        
        // Select the default payment method
        if let row = self.cellManager.activeCells.index(of: .paymentAmounts),
            let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? PaymentAmountsTableViewCell,
            let paymentSession = self.paymentSession,
            let itemIndex = paymentSession.availablePaymentAmountMethods.index(of: paymentSession.selectedPaymentAmountMethod) {
            
            cell.collectionView.selectItem(at: IndexPath(item: itemIndex, section: 0), animated: false, scrollPosition: [])
            cell.collectionView.reloadData()
        }
        
        self.setDefaultPaymentDate()
    }
    
    private func setDefaultPaymentDate() {
        
        if self.cellManager.paymentMode != PaymentMode.scheduled {
            self.paymentSession?.paymentDate = Date()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Segue Handling
    //--------------------------------------------------------------------------
    
    @IBAction func goBack(segue: UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        ApplicationContext.shared.paymentsManager.activeMakePaymentSession = self.paymentSession
        
        if segue.identifier == "PaymentMethods",
            let paymentMethods = segue.destination as? PaymentMethodsViewController {
            let paymentIndex = (sender as? UIButton)?.tag ?? 0
            
            paymentMethods.paymentMode = .selectingForPayment
            paymentMethods.cashMode = cellManager.paymentMode == .single ? .cashEnabled : .cashDisabled
            
            paymentMethods.paymentMethodSelectedHandler = { [weak self] (paymentMethod) in
                guard let paymentSession = self?.paymentSession, let `self` = self else {
                    return
                }
                
                let paymentEntry = paymentSession.paymentEntries[paymentIndex]
                paymentEntry.paymentMethod = paymentMethod
                
                self.tableView.reloadRows(at: [ IndexPath(row: self.cellManager.paymentCellIndexes[paymentIndex], section: 0) ], with: .automatic)
            }
        } else if segue.identifier == "showSupportVC", let vc = segue.destination as? SupportVC {
            vc.contextualHelpString = NSLocalizedString("contextualhelp.paylessthanowe", comment: "Q: Can I pay less than what I owe?\n\nA: In some cases, we allow you to make a payment that is slightly less than the amount due. Please chat with one our Customer Service Representatives to review your policy, verify an amount that may be accepted and obtain approval.")
        }
    }
    
    
    //MARK: - Private
    var remainingSplitCellAmount: Decimal?
}


// MARK: - Private
extension MakePaymentViewController {
    private func startPaymentSession() {
        ApplicationContext.shared.paymentsManager.startMakePaymentSession()
        self.paymentSession = ApplicationContext.shared.paymentsManager.activeMakePaymentSession
        self.paymentSession?.paymentEntries = self.resizePaymentsArray(numberOfPayments: 1)
        self.tableView.reloadData()
    }
    
    private func resizePaymentsArray(numberOfPayments: Int) -> [MakePaymentEntry] {
        let oldPaymentMethods:[MakePaymentEntry] = self.paymentSession?.paymentEntries ?? [MakePaymentEntry]()
        var newPaymentMethods: [MakePaymentEntry] = [MakePaymentEntry]()
        
        for i in 0..<numberOfPayments {
            let method = MakePaymentEntry()
            
            // set method amount to amount from old entry
            if i < oldPaymentMethods.count {
                method.amount = 0
                method.paymentMethod = oldPaymentMethods[i].paymentMethod
            }
            
            // if no value, set first row to the total amount
            if method.amount < 0.01 && i == 0 {
                method.amount = paymentSession?.amount ?? 0
            }
            
            newPaymentMethods.append(method)
        }
        
        return newPaymentMethods
    }
    
    private func selectOtherPaymentAmount() {
        if let row = self.cellManager.activeCells.index(of: .paymentAmounts),
            let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? PaymentAmountsTableViewCell,
            let item = self.paymentSession!.availablePaymentAmountMethods.index(of: .otherAmount) {
            cell.collectionView.selectItem(at: IndexPath(item: item, section: 0), animated: false, scrollPosition: [])
        }
        
        if let paymentSession = ApplicationContext.shared.paymentsManager.activeMakePaymentSession {
            paymentSession.selectedPaymentAmountMethod = .otherAmount
        }
    }
    
    private func selectAmountDue() {
        if let row = self.cellManager.activeCells.index(of: .paymentAmounts),
            let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? PaymentAmountsTableViewCell,
            let item = self.paymentSession!.availablePaymentAmountMethods.index(of: .currentAmountDue) {
            cell.collectionView.selectItem(at: IndexPath(item: item, section: 0), animated: false, scrollPosition: [])
        }
        
        if let paymentSession = ApplicationContext.shared.paymentsManager.activeMakePaymentSession {
            paymentSession.selectedPaymentAmountMethod = .currentAmountDue
        }
    }
    
    // Must call tableView.reloadData to see changes
    private func setPaymentAmount(_ amount: Decimal) {
        guard let paymentSession = self.paymentSession else {
            return
        }
        
        paymentSession.amount = amount
        
        guard self.cellManager.paymentMode == PaymentMode.split else {
            paymentSession.paymentEntries.first?.amount = amount
            return
        }
        
        var remainingAmount =  amount
        
        for i in (0..<paymentSession.paymentEntries.count).reversed() {
            let paymentEntry = paymentSession.paymentEntries[i]
            
            // some change left over, assign to this card
            if remainingAmount - paymentEntry.amount < 0 {
                paymentEntry.amount = remainingAmount
            }
            
            remainingAmount -= paymentEntry.amount
        }
    }
    
    private func updateSplitPaymentAmount(field: CurrencyTextField? = nil) {
        guard self.cellManager.paymentMode == .split else {
            return
        }
        
        guard let paymentSession = self.paymentSession, let dueDetails = self.dueDetails, let amountDue = dueDetails.currentAmountDue else {
            return
        }
        
        var totalAmount = Decimal(0)
        
        for i in 0..<paymentSession.paymentEntries.count {
            let paymentEntry = paymentSession.paymentEntries[i]
            
            // set split pay amount to what's stored by default
            var splitPayAmount = paymentEntry.amount
            
            // if this is the updated field, update value in model
            if field === splitPaymentField(index: i) {
                
                splitPayAmount = field!.value
                paymentEntry.amount = splitPayAmount
            }
            
            totalAmount += splitPayAmount
        }
        
        // only update the total amount when split pay total is more
        if totalAmount > amountDue.rawValue {
            self.totalAmountField()?.value = totalAmount
            paymentSession.amount = totalAmount
            self.selectOtherPaymentAmount()
            
        } else {
            self.totalAmountField()?.value = amountDue.rawValue
            paymentSession.amount = amountDue.rawValue
            self.selectAmountDue()
            
            if field != nil { // Coming from text field edit
                
                remainingSplitCellAmount = amountDue.rawValue - totalAmount
                
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(autopopulateNextSplitPaymentCell), object: nil)
                self.perform(#selector(autopopulateNextSplitPaymentCell), with: nil, afterDelay: 0.5)
                
            }
        }
    }
    
    @objc func autopopulateNextSplitPaymentCell() {
        
        guard let remainingAmount = remainingSplitCellAmount else {
            return
        }
        
        let splitPayIndexes = self.cellManager.splitPaymentCellIndexes
        for index in splitPayIndexes {
            guard let cell = self.tableView.cellForRow(at: IndexPath.init(row: index, section: 0) ) as? SplitPayWithTableViewCell, let paymentSession = self.paymentSession, let firstSplitPayIndex = self.cellManager.firstSplitPaymentCell() else {
                continue
            }
            
            if !cell.paymentAmountField.modified {
                cell.paymentAmountField.setValue(newValue: remainingAmount, animated: true)
                
                let paymentIndex = index - firstSplitPayIndex
                
                let paymentEntry = paymentSession.paymentEntries[paymentIndex]
                paymentEntry.suggestedAmount = remainingAmount
                
                return // Only update the first split payment cell, unmodified, which was found
            }
        }
    }
    
    var paymentDateCell: PaymentDateTableViewCell? {
        get {
            guard let row = self.cellManager.activeCells.index(of: .paymentDate) else {
                return nil
            }
            
            guard let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? PaymentDateTableViewCell else {
                return nil
            }
            
            return cell
        }
    }
    
    private func totalAmountField() -> CurrencyTextField? {
        guard let row = self.cellManager.activeCells.index(of: .paymentAmount) else {
            return nil
        }
        
        guard let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? PaymentAmountTableViewCell else {
            return nil
        }
        
        return cell.amountTextField
    }
    
    private func splitPaymentField(index: Int) -> CurrencyTextField? {
        
        guard let row = self.cellManager.firstSplitPaymentCell() else {
            return nil
        }
        guard let cell = self.tableView.cellForRow(at: IndexPath(row: row + index, section: 0)) as? SplitPayWithTableViewCell else {
            return nil
        }
        
        return cell.paymentAmountField
    }
    
    private func changeDateSelected() {
        guard let paymentDateCell = self.paymentDateCell else {
            return
        }
        
        paymentDateCell.showDateSelector()
    }
    
    private func schedulePaymentSelected() {
        
        if let dueDetails = dueDetails, let paymentDate = ApplicationContext.shared.paymentsManager.scheduledPaymentDate, let dueDate = dueDetails.currentDueDate, let dueDateDisplay = dueDetails.dueDateDisplay, paymentDate > dueDate {
            
            var message = NSLocalizedString("payments.ui.after-due-date-alert.message", comment: "")
            message.insertString(string: dueDateDisplay, replacingTag: "|date|")
            
            let alert = UIAlertController(title: NSLocalizedString("alert.title", comment: ""), message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("payments.ui.after-due-date-alert.continue", comment: ""), style: .default, handler: { [weak self] action in
                
                self?.schedulePayment()
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("payments.ui.after-due-date-alert.change-date", comment: ""), style: .default, handler: { [weak self] action in
                
                self?.changeDateSelected()
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.schedulePayment()
    }
    
    private func schedulePayment() {
        
        handlePaymentErrors {
            let loadingMessage = NSLocalizedString("payments.ui.processing", comment: "")
            
            LoadingView.show(inView: self.view, type: .hud, displayText: loadingMessage, animated: true)
            
            let paymentManager = ApplicationContext.shared.paymentsManager
            try paymentManager.submitScheduledPayment {[weak self](successfulPayments: [MakePaymentEntry], failedPayments: [MakePaymentEntry]) in
                guard let weakself = self else {
                    return
                }
                
                func finish() {
                    weakself.navigationController?.popToRootViewController(animated: true)
                    weakself.delegate?.makePaymentsFinished(successfulPayments: successfulPayments, failedPayments: failedPayments)
                }
                
                guard successfulPayments.count > 0 else {
                    LoadingView.hide(inView: weakself.view, animated: true, complete: {
                        finish()
                    })
                    return
                }
                
                LoadingView.showComplete(animated: true, inView: weakself.view) {
                    finish()
                }
            }
        }
    }
    
    private func submitPayment() {
        
        self.view.endEditing(false)
        
        ApplicationContext.shared.paymentsManager.activeMakePaymentSession = self.paymentSession
        
        handlePaymentErrors({
            let paymentManager = ApplicationContext.shared.paymentsManager
            try paymentManager.submitImmediatePayment {[weak self](successfulPayments: [MakePaymentEntry], failedPayments: [MakePaymentEntry]) in
                guard let weakself = self else {
                    return
                }
                
                if failedPayments.count > 0 {
                    LoadingView.hide(inView: weakself.view, animated: true)
                    weakself.showDeclinedPayments(successfulPayments, failedPayments)
                } else {
                    LoadingView.showComplete(animated: true, inView: weakself.view) {
                        weakself.navigationController?.popToRootViewController(animated: true)
                        weakself.delegate?.makePaymentsFinished(successfulPayments: successfulPayments, failedPayments: failedPayments)
                    }
                }
            }
            let loadingMessage = NSLocalizedString("payments.ui.processing", comment: "")
            LoadingView.show(inView: self.view, type: .hud, displayText: loadingMessage, animated: true)
        })
        
    }
    
    private func handlePaymentErrors(_ execute: ()throws -> ()) {
        do {
            try execute()
            
        } catch SubmitPaymentErrorType.belowSplitPaymentTotal {
            let title = NSLocalizedString("payments.errors.title", comment: "")
            let message = NSLocalizedString("payments.errors.split-payments-below", comment: "")
            paymentValidationAlert(title, message: message)
            
        } catch SubmitPaymentErrorType.badPaymentDate {
            let title = NSLocalizedString("payments.errors.title", comment: "")
            let message = NSLocalizedString("payments.errors.bad-payment-date", comment: "")
            
            paymentValidationAlert(title, message: message)
            
        } catch SubmitPaymentErrorType.belowMinimumPayment {
            let title = NSLocalizedString("payments.errors.title", comment: "")
            let message = NSLocalizedString("payments.errors.payment-below-min", comment: "")
            
            paymentValidationAlert(title, message: message)
            
        } catch SubmitPaymentErrorType.aboveMaximumPayment {
            let title = NSLocalizedString("payments.errors.title", comment: "")
            let message = NSLocalizedString("payments.errors.payment-above-max", comment: "")
            
            paymentValidationAlert(title, message: message)
            
        } catch SubmitPaymentErrorType.noPaymentMethods {
            let title = NSLocalizedString("payments.errors.title", comment: "")
            let message = NSLocalizedString("payments.errors.payment-method-missing", comment: "")
            
            paymentValidationAlert(title, message: message)
        } catch {
            let title = NSLocalizedString("payments.errors.unknown-title", comment: "")
            paymentValidationAlert(NSLocalizedString(title, comment: ""), message: error.localizedDescription)
        }
        
    }
    
    private func paymentValidationAlert(_ title: String, message: String) {
        LoadingView.hide(inView: self.view, animated: false)
        self.alert(title, message: message)
    }
    
    private func showDeclinedPayments(_ success: [MakePaymentEntry], _ declined: [MakePaymentEntry]) {
        let vc = UIStoryboard(name: "Payments", bundle: nil)
            .instantiateViewController(withIdentifier: "declined-payments") as! PaymentsDeclinedViewController
        
        vc.failedPayments = declined
        vc.successfulPayments = success
        vc.delegate = self.delegate
        
        vc.paymentSession = self.paymentSession
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // Alerts that appear at the top of the screen
    fileprivate func showSlidableAlert(withTitle title: String, message: String, type: SlidableAlertType, longDelay: Bool = false) {
        
        let slidableAlertView = SlidableAlertView.create(withTitle: title, withMessage: message, type: type)
        
        if longDelay {
            self.baseNavigationController?.addLongerSupplementaryView(slidableAlertView, animated: true)
            
        } else {
            self.baseNavigationController?.addMomentarySupplementaryView(slidableAlertView, animated: true)
        }
    }
}



// MARK: - UITableViewDataSource, UITableViewDelegate
extension MakePaymentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellManager.activeCells.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let isSplitPayCell = self.cellManager.activeCells[indexPath.row] == .splitPayWith
        let notLastSplitPaymentCell = self.cellManager.numberOfSplitPaymentCells() > 1
        
        return isSplitPayCell && notLastSplitPaymentCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && self.cellManager.paymentMode == .split {
            let paymentEntryIndex = indexPath.row - self.cellManager.firstSplitPaymentCell()!
            
            self.paymentSession?.paymentEntries.remove(at: paymentEntryIndex )
            self.cellManager.activeCells.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
            self.updateSplitPaymentAmount()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let activeCellIdentifier = self.cellManager.activeCells[indexPath.row]
        
        switch activeCellIdentifier {
        case .paymentAmounts:
            let cell = tableView.dequeueReusableCell(withIdentifier: activeCellIdentifier.rawValue, for: indexPath) as! PaymentAmountsTableViewCell
            cell.collectionView.allowsMultipleSelection = false
            cell.collectionView.delegate = self
            return cell
            
        case .paymentAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: activeCellIdentifier.rawValue, for: indexPath) as! PaymentAmountTableViewCell
            cell.amountTextField.value = self.paymentSession?.amount ?? 0
            return cell
            
        case .splitPaymentYesNo:
            let cell = tableView.dequeueReusableCell(withIdentifier: activeCellIdentifier.rawValue, for: indexPath) as! SplitPaymentsYesNoTableViewCell
            cell.yesNoButton.value = self.cellManager.paymentMode == .split
            cell.yesNoButton.addTarget(self, action: #selector(splitPaymentToggled(_: )), for: .valueChanged)
            return cell
            
        case .addAnotherPayment:
            let cell = tableView.dequeueReusableCell(withIdentifier: activeCellIdentifier.rawValue, for: indexPath) as! AddAnotherPaymentTableViewCell
            cell.button.addTarget(self, action: #selector(addPaymentTouched), for: .touchUpInside)
            return cell
            
        case .splitPayWith:
            let cell = tableView.dequeueReusableCell(withIdentifier: activeCellIdentifier.rawValue, for: indexPath) as! SplitPayWithTableViewCell
            let paymentIndex = indexPath.row - (cellManager.firstSplitPaymentCell() ?? indexPath.row)
            
            cell.paymentMethodLabel.text = NSLocalizedString("payments.ui.select-splitpay-method", comment: "")
            
            guard paymentIndex < self.paymentSession?.paymentEntries.count ?? 0 else {
                return cell
            }
            
            let paymentEntry = self.paymentSession!.paymentEntries[paymentIndex]
            
            if let paymentMethod = paymentEntry.paymentMethod {
                cell.paymentMethodLabel.text = PaymentFormatter.accountLabel(for: paymentMethod)
            } else {
                cell.paymentMethodLabel.text = NSLocalizedString("payments.ui.select-splitpay-method", comment: "")
            }
            
            let amountToShow: Decimal!
            if let suggestedAmount = paymentEntry.suggestedAmount, paymentEntry.amount == 0 {
                amountToShow = suggestedAmount
            } else {
                amountToShow = paymentEntry.amount
            }
            
            cell.paymentAmountField.text = PaymentFormatter.currency(for: amountToShow)
            cell.paymentMethodButton.addTarget(self, action: #selector(selectPaymentMethod(_: )), for: .touchUpInside)
            cell.paymentMethodButton.tag = paymentIndex
            
            return cell
            
        case .singlePayWith:
            let cell = tableView.dequeueReusableCell(withIdentifier: activeCellIdentifier.rawValue, for: indexPath) as! PayWithTableViewCell
            if let paymentEntry = self.paymentSession?.paymentEntries.first,
                let paymentMethod = paymentEntry.paymentMethod {
                
                cell.paymentMethodLabel.text = PaymentFormatter.accountLabel(for: paymentMethod)
            }
            else {
                cell.paymentMethodLabel.text = NSLocalizedString("Select", comment: "")
            }
            return cell
            
        case .paymentDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: activeCellIdentifier.rawValue, for: indexPath) as! PaymentDateTableViewCell
            cell.textField.delegate = self
            cell.dateChangeAllowed = self.cellManager.paymentMode == .scheduled
            
            if let paymentDate = self.paymentSession?.paymentDate {
                cell.paymentDateLabel.text = DateFormatter.monthDayYear.string(from: paymentDate)
            }
            else {
                cell.paymentDateLabel.text = nil
            }
            return cell
            
        case .submitPayment:
            let cell = tableView.dequeueReusableCell(withIdentifier: activeCellIdentifier.rawValue, for: indexPath) as! SubmitPaymentTableViewCell
            cell.actionHandler = { [weak self] in
                self?.submitPayment()
            }
            return cell
            
        case .schedulePayment:
            let cell = tableView.dequeueReusableCell(withIdentifier: activeCellIdentifier.rawValue, for: indexPath) as! SubmitPaymentTableViewCell
            cell.actionHandler = { [weak self] in
                self?.schedulePaymentSelected()
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    @objc
    func addPaymentTouched() {
        self.paymentSession?.paymentEntries.append(MakePaymentEntry())
        let insertAtRow = self.cellManager.addSplitPaymentCell()
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: insertAtRow, section: 0)], with: .left)
        self.tableView.endUpdates()
    }
    
    @objc
    func splitPaymentToggled(_ sender: YesNoSegmentControl) {
        let splitPaymentsOn = sender.value
        
        var existingCellIndexPaths: [IndexPath]!
        var indexToStartAddingTo: Int!
        
        if splitPaymentsOn, let existingSinglePayWithIndex = self.cellManager.activeCells.index(of: .singlePayWith), let existingPaymentDateIndex = self.cellManager.activeCells.index(of: .paymentDate) {
            
            existingCellIndexPaths = [ IndexPath(row: existingSinglePayWithIndex, section: 0), IndexPath(row: existingPaymentDateIndex, section: 0) ]
            indexToStartAddingTo = existingSinglePayWithIndex
            
        } else if !splitPaymentsOn, let firstSplitPayIndex = self.cellManager.firstSplitPaymentCell(), let addAnotherPaymentIndex = self.cellManager.activeCells.index(of: MakePaymentCellIdentifiers.addAnotherPayment) {
            
            let numberOfSplitPayCellsToRemove = self.cellManager.numberOfSplitPaymentCells()
            
            existingCellIndexPaths = []
            
            for index in 0..<numberOfSplitPayCellsToRemove {
                existingCellIndexPaths.append( IndexPath(row: firstSplitPayIndex + index, section: 0) )
            }
            
            existingCellIndexPaths.append( IndexPath(row: addAnotherPaymentIndex, section: 0) )
            
            indexToStartAddingTo = firstSplitPayIndex
        }
        
        guard existingCellIndexPaths != nil, indexToStartAddingTo != nil else {
            self.tableView.reloadData()
            return
        }
        
        let countBefore = self.cellManager.activeCells.count
        
        if splitPaymentsOn {
            let defaultNumberOfPayments = 2
            self.cellManager.enableSplitPay(numberOfPayments: defaultNumberOfPayments)
            self.paymentSession?.paymentEntries = resizePaymentsArray(numberOfPayments: defaultNumberOfPayments)
            
        } else {
            self.cellManager.enableSinglePay()
            self.paymentSession?.paymentEntries = resizePaymentsArray(numberOfPayments: 1)
        }
        
        let countAfter = self.cellManager.activeCells.count
        
        let numberOfRowsToAdd = max(countAfter - countBefore + existingCellIndexPaths.count, 0)
        
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: existingCellIndexPaths, with: .automatic)
        
        for index in 0..<numberOfRowsToAdd {
            self.tableView.insertRows(at: [ IndexPath.init(row: indexToStartAddingTo + index, section: 0) ], with: .automatic)
        }
        
        self.tableView.endUpdates()
    }
    
    @objc
    func selectPaymentMethod(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "PaymentMethods", sender: sender)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let activeCellIdentifier = self.cellManager.activeCells[indexPath.row]
        switch activeCellIdentifier {
        case .singlePayWith:
            self.performSegue(withIdentifier: "PaymentMethods", sender: self)
            
        default:
            // Do nothing
            break
        }
        
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MakePaymentViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.paymentSession?.availablePaymentAmountMethods.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let paymentAmountMethod = self.paymentSession!.availablePaymentAmountMethods[indexPath.item]
        if paymentAmountMethod == .otherAmount {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MakePaymentCellIdentifiers.paymentAmountOther.rawValue, for: indexPath) as! PaymentAmountOtherCollectionViewCell
            
            if self.paymentSession!.selectedPaymentAmountMethod == paymentAmountMethod {
                cell.isSelected = true
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MakePaymentCellIdentifiers.paymentAmount.rawValue, for: indexPath) as! PaymentAmountCollectionViewCell
            
            if let dueDetails = self.dueDetails {
                var amount: Decimal = 0
                var message: String = paymentAmountMethod.rawValue
                switch paymentAmountMethod {
                case .currentAmountDue:
                    amount = dueDetails.currentAmountDue?.rawValue ?? 0
                    message = dueDetails.currentAmountDueLabel ?? ""
                    
                case .fullPayoff:
                    amount = dueDetails.fullPayoffAmount?.rawValue ?? 0
                    message = dueDetails.fullPayoffAmountLabel ?? ""
                    
                case .nonRenewableFullPayoff:
                    amount = dueDetails.nonRenewableFullPayoffAmount?.rawValue ?? 0
                    message = dueDetails.nonRenewableFullPayoffAmountLabel ?? ""
                    
                case .paidInFullRenewal:
                    amount = dueDetails.paidInFullRenewalAmount?.rawValue ?? 0
                    message = dueDetails.paidInFullRenewalAmountLabel ?? ""
                    
                case .renewalDownPayment:
                    amount = dueDetails.renewalDownPaymentAmount?.rawValue ?? 0
                    message = dueDetails.renewalDownPaymentAmountLabel ?? ""
                    
                case .renewalDownPaymentPlusCurrentAmountDue:
                    amount = dueDetails.renewalDownPaymentPlusCurrentDueAmount?.rawValue ?? 0
                    message = dueDetails.renewalDownPaymentPlusCurrentDueAmountLabel ?? ""
                    
                default:
                    break
                }
                
                cell.amountLabel.text = PaymentFormatter.currency(for: amount)
                cell.descriptionLabel.text = message
                
                if self.paymentSession!.selectedPaymentAmountMethod == paymentAmountMethod {
                    cell.isSelected = true
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let paymentSession = ApplicationContext.shared.paymentsManager.activeMakePaymentSession else {
            return
        }
        
        let paymentAmountMethod = paymentSession.availablePaymentAmountMethods[indexPath.item]
        paymentSession.selectedPaymentAmountMethod = paymentAmountMethod
        
        if let dueDetails = self.dueDetails {
            var amount: Decimal = 0
            switch paymentAmountMethod {
            case .currentAmountDue:
                amount = dueDetails.currentAmountDue?.rawValue ?? 0
                
            case .fullPayoff:
                amount = dueDetails.fullPayoffAmount?.rawValue ?? 0
                
            case .nonRenewableFullPayoff:
                amount = dueDetails.nonRenewableFullPayoffAmount?.rawValue ?? 0
                
            case .paidInFullRenewal:
                amount = dueDetails.paidInFullRenewalAmount?.rawValue ?? 0
                
            case .renewalDownPayment:
                amount = dueDetails.renewalDownPaymentAmount?.rawValue ?? 0
                
            case .renewalDownPaymentPlusCurrentAmountDue:
                amount = dueDetails.renewalDownPaymentPlusCurrentDueAmount?.rawValue ?? 0
                
            case .otherAmount:
                amount = dueDetails.minimumPayment?.rawValue ?? 0
            }
            
            
            self.setPaymentAmount(amount)
            self.tableView.reloadData()
        }
    }
}


extension MakePaymentViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.bounds.width - inset - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        print(widthPerItem)
        return CGSize(width: widthPerItem, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.bottom * 2.0
    }
    
}

// MARK: - UITextFieldDelegate
extension MakePaymentViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.hideKeyboardWhenTapped = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.hideKeyboardWhenTapped = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + 0.1) { [weak self] in
            
            guard let `self` = self else {
                return
            }
            
            if let currencyField = textField as? CurrencyTextField {
                
                if textField === self.totalAmountField() { //Total amount field
                    
                    self.selectOtherPaymentAmount()
                    self.setPaymentAmount(currencyField.value)
                    
                } else { //Split payment field
                    
                    self.updateSplitPaymentAmount(field: currencyField)
                }
                
            } else if textField === self.paymentDateCell?.textField, let dateValue = self.paymentDateCell?.value {
                ApplicationContext.shared.paymentsManager.scheduledPaymentDate = dateValue
                self.view.layoutIfNeeded()
            }
        }
        
        return true
    }
}


// MARK: - Notifications
extension MakePaymentViewController {
    @objc func adjustForKeyboard(_ notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            self.tableView.contentInset = UIEdgeInsets.zero
        } else {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
        
        // TODO: Account for split payment text fields
        let amountCellIndex = self.cellManager.activeCells.index(of: .paymentAmount) ?? 0
        self.tableView.scrollToRow(at: IndexPath(row: amountCellIndex, section: 0), at: .top, animated: true)
    }
}
