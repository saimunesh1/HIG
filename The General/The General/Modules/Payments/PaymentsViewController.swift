//
//  PaymentsViewController.swift
//  The General
//
//  Created by Derek Bowen on 10/10/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import QuickLook

class PaymentsViewController: UIViewController {
    
    fileprivate var alerts: [PaymentAlert] = []

    enum Cells: Int {
        case summary
        case alert
        case payNow
        case schedulePayment
        case accountBalance
        case autoPay
        case history
        case savedMethods
    }
    var activeCells: [Cells]?
    
    @IBOutlet weak var tableView: UITableView!
    
    var dueDetails: PaymentsGetDueDetailsResponse?
    var currentInvoice: HistoricalDocumentResponse?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    let kStoryboardShowPaymentMethods = "Show Saved Payment Methods"
    let kStoryboardShowPaymentHistory = "Show Payment History"
    let kStoryboardAutoPayEnabledSegue = "Show Auto Pay Enabled"
    let kStoryboardAutoPayDisabledSegue = "Show Auto Pay Disabled"

    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance(whenContainedInInstancesOf: [QLPreviewController.self]).tintColor = .tgGreen
    }
    
    lazy var forcedTopContraint: NSLayoutConstraint = self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
    
    // Alerts that appear at the top of the screen
    fileprivate func showSlidableAlert(withMessage message: String, type: SlidableAlertType, longDelay: Bool = false) {
        
        let slidableAlertView = SlidableAlertView.create(withMessage: message, type: type)
        
        if longDelay {
            self.baseNavigationController?.addLongerSupplementaryView(slidableAlertView, animated: true)
            
        } else {
            self.baseNavigationController?.addMomentarySupplementaryView(slidableAlertView, animated: true)
        }
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        self.navigationController?.showNavigationBarShadow()
		// TODO: Only if we got here from drawer
		baseNavigationController?.showMenuButton()
	}
	
    override func viewDidAppear(_ animated: Bool) {
        LoadingView.show(inView: self.view, type: .hud, animated: true)
        
        ApplicationContext.shared.paymentsManager.getDueDetails(forPolicy: SessionManager.policyNumber ?? "") { [weak self] (innerClosure) in
            guard let weakSelf = self else { return }
            
            LoadingView.hide(inView: weakSelf.view, animated: true)
            
            do {
                weakSelf.dueDetails = try innerClosure()
                weakSelf.updateView()
                
                if weakSelf.needToShowPaymentAlerts {
                    weakSelf.showPaymentAlerts()
                }
                
                if let details = weakSelf.dueDetails, details.autoDebitEnabled {
                    self?.showAutoPayScheduledDateAlert()
                }
            }
            catch let error {
                // TODO: Better error handling
                let alert = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
                    self?.dismiss(animated: true, completion: nil)
                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func showAutoPayScheduledDateAlert() {
        
        guard let dueDate = self.dueDetails?.dueDateDisplay else { // Assuming autopay always occurs on the due-date
            return
        }
        
        let title = NSLocalizedString("payments.alert.autopay.scheduled.title", comment: "")
        var message = NSLocalizedString("payments.alert.autopay.scheduled.message", comment: "")
        message.insertString(string: dueDate, replacingTag: "|date|")
        
        let alert = PaymentAlert(title: title, description: message)
        
        guard !self.alerts.contains(alert) else {
            return
        }
        
        self.alerts.append(alert)
        self.updateView()
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func showCurrentInvoice(_ sender: UIButton) {
        LoadingView.show(inView: self.view, type: .hud, animated: true)
        ApplicationContext.shared.documentsManager.getHistoricalDocumentInfo(forPolicy: SessionManager.policyNumber ?? "", docType: .currentInvoice) { [weak self] (innerClosure) in
            guard let weakSelf = self else { return }
            LoadingView.hide(inView: weakSelf.view, animated: true)
            do {
                let currentInvoiceInfo = try innerClosure()
                weakSelf.fetchCurrentInvoice(for: currentInvoiceInfo)
            }
            catch let error {
                // TODO: Better error handling
                let alert = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
                    self?.dismiss(animated: true, completion: nil)
                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Segue Handling
    //--------------------------------------------------------------------------

    @IBAction func goBack(segue: UIStoryboardSegue) { }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let paymentMethodsVC = segue.destination as? PaymentMethodsViewController {
            paymentMethodsVC.dueDetails = self.dueDetails
            paymentMethodsVC.paymentMode = .editing
        }
        
        if let makePaymentVC = segue.destination as? MakePaymentViewController {
            makePaymentVC.delegate = self
        
            if segue.identifier == "SchedulePayment" {
                makePaymentVC.cellManager.enableSchedulePay()
            }
            
            else if segue.identifier == "MakePayment" {
                makePaymentVC.cellManager.enableSinglePay()
            }

        }
        
        if segue.identifier == kStoryboardAutoPayEnabledSegue, let destination = segue.destination as? AutoPayStatusViewController {
            
            guard let display = self.dueDetails?.autopayPaymentMethodDisplay else {
                return
            }
            
            destination.autoPayMethodDisplay = display
        }
		
		if segue.identifier == "showSupportVC", let vc = segue.destination as? SupportVC, let dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo, dashboardInfo.isExpiredPolicy && dashboardInfo.isRenewable {
			vc.contextualHelpString = NSLocalizedString("contextualhelp.renewalpaperwork", comment: "Q: When will I receive my renewal paperwork?\n\nA: In most states, your renewal offer will generate in 30 to 45 days before the expiration date of your current policy.")
		}
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate var showPaymentAlertsWhenReady = false
    fileprivate var successfulPayments: [MakePaymentEntry]?
    fileprivate var failedPayments: [MakePaymentEntry]?
    
    fileprivate var needToShowPaymentAlerts = false
    
    fileprivate var autoPayEnabled: Bool {
        get {
            return self.dueDetails?.autoDebitEnabled ?? false
        }
    }
    
    fileprivate func showPaymentAlerts() {
        
        guard self.isViewLoaded else {
            needToShowPaymentAlerts = true
            return
        }
        
        guard let successfulPayments = self.successfulPayments, let failedPayments = self.failedPayments else {
            return
        }
        
        var totalPaid: Decimal = 0
        var slidableAlertsShown = 0
        
        for paymentMade in successfulPayments {
            
            totalPaid += paymentMade.amount
            
            guard let formattedPaymentAmount = NumberFormatter.currency.string(from: (paymentMade.amount as NSNumber)) else {
                continue
            }
            
            var topSuccessMessage = NSLocalizedString("payments.alert.successfulpaymentprocessing", comment: "")
            topSuccessMessage.insertString(string: formattedPaymentAmount, replacingTag: "|number|")
            
            var lowerSuccessMessage = NSLocalizedString("payments.alert.successfulpaymentwillprocess", comment: "")
            lowerSuccessMessage.insertString(string: formattedPaymentAmount, replacingTag: "|number|")
            
            self.showSlidableAlert(withMessage: topSuccessMessage, type: .positive)
            slidableAlertsShown += 1
            
            let alert = PaymentAlert(title: "Payment pending", description: lowerSuccessMessage)
            self.alerts.append(alert)
            self.updateView()
        }
        
        for failedPayment in failedPayments {
            
            guard let formattedPaymentAmount = NumberFormatter.currency.string(from: (failedPayment.amount as NSNumber)) else {
                continue
            }
            
            var topFailureMessage = NSLocalizedString("payments.alert.failedpaymentprocessing", comment: "")
            topFailureMessage.insertString(string: formattedPaymentAmount, replacingTag: "|number|")
            
            self.showSlidableAlert(withMessage: topFailureMessage, type: .failure)
            slidableAlertsShown += 1
        }
        
        // If there is still a remaining balance, show an alert
        if let details = self.dueDetails, let dueDateDisplay = details.dueDateDisplay, let amountDue = details.currentAmountDue, amountDue.rawValue > totalPaid {
            
            var remainingDueMessage = NSLocalizedString("payments.alert.pleasepayfullamount", comment: "")
            remainingDueMessage.insertString(string: dueDateDisplay, replacingTag: "|date|")
            
            self.showSlidableAlert(withMessage: remainingDueMessage, type: .attention, longDelay: true)
            slidableAlertsShown += 1
        }
        
        self.forcedTopContraint.isActive = slidableAlertsShown == 1 ? true : false
        
        self.successfulPayments = nil
        self.failedPayments = nil
    }

    private func fetchCurrentInvoice(for info: HistoricalDocumentInfoResponse) {
        LoadingView.show(inView: self.view, type: .hud, animated: true)
        let request = HistoricalDocumentRequest(pdfName: info.pdfName, startPage: info.startPage, endPage: info.endPage, detailKey: info.detailKey)
        ApplicationContext.shared.documentsManager.getHistoricalDocument(forPolicy: SessionManager.policyNumber ?? "", request: request) { [weak self] (innerClosure) in
            guard let weakSelf = self else { return }
            LoadingView.hide(inView: weakSelf.view, animated: true)
            do {
                let invoice = try innerClosure()
                weakSelf.currentInvoice = invoice
                let previewController = QLPreviewController()
                previewController.modalPresentationStyle = .overCurrentContext
                previewController.dataSource = self
                weakSelf.present(previewController, animated: true, completion: nil)

            }
            catch let error {
                // TODO: Better error handling
                let alert = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
                    self?.dismiss(animated: true, completion: nil)
                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}

//==============================================================================
// MARK: - Make Payment Delegate
//==============================================================================

extension PaymentsViewController: MakePaymentViewControllerDelegate {
    
    func makePaymentsFinished(successfulPayments: [MakePaymentEntry], failedPayments: [MakePaymentEntry]) {
        
        self.successfulPayments = successfulPayments
        self.failedPayments = failedPayments
        
        self.showPaymentAlerts()
    }
}

//==============================================================================
// MARK: - Internal
//==============================================================================

extension PaymentsViewController {
    
    fileprivate func buildActiveCells() {
        var cells: [Cells] = [
            .summary
        ]
        
        for _ in 0..<self.alerts.count {
            cells.append(.alert)
        }
        
        cells.append(.payNow)
        cells.append(.schedulePayment)
        cells.append(.accountBalance)
        
        // Bottom buttons
        if let details = self.dueDetails, details.autoDebitAvailable {
            cells.append(.autoPay)
        }
        
        cells.append(.history)
        cells.append(.savedMethods)
        
        self.activeCells = cells
    }
    
    fileprivate func setupAlertCell(_ cell: PaymentAlertTableViewCell, atIndexPath indexPath: IndexPath) {
        let indexOfAlert = indexPath.row - self.firstAlertCellIndex!
        let alertToShow = self.alerts[indexOfAlert]
        cell.setup(withAlert: alertToShow)
    }
    
    fileprivate var firstAlertCellIndex: Int? {
        get {
            guard let cellTypes = self.activeCells else {
                return nil
            }
            
            for (index, type) in cellTypes.enumerated() where type == .alert {
                return index
            }
            return nil
        }
    }
    
    fileprivate func updateView(animated: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            guard let previousCells = weakSelf.activeCells else {
                weakSelf.buildActiveCells()
                if animated {
                    UIView.transition(with: weakSelf.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                        weakSelf.tableView.reloadData()
                    })
                } else {
                    weakSelf.tableView.reloadData()
                }
                return
            }
            
            if animated {
                weakSelf.tableView.beginUpdates()
            }
            
            weakSelf.buildActiveCells()
            
            var indexesOfRemovedCells: [IndexPath] = []
            var indexesOfAddedCells: [IndexPath] = []
            
            
            // Check for newly added cells
            
            var newCells: [Cells] = weakSelf.activeCells!
            
            var index = 0
            while index < newCells.count {
                
                let newItem = newCells[index]
                
                if index < previousCells.count {
                    let itemInPrevious = previousCells[index]
                    if itemInPrevious != newItem {
                        newCells.remove(at: index)
                        indexesOfAddedCells.append( IndexPath(row: index, section: 0) )
                        continue
                    }
                }
                
                index += 1
            }
            
            // Check for removed cells
            
            for (index, previousType) in previousCells.enumerated() {
                if !weakSelf.activeCells!.contains(previousType) {
                    indexesOfRemovedCells.append( IndexPath(row: index, section: 0) )
                }
            }
            
            if animated {
                weakSelf.tableView.deleteRows(at: indexesOfRemovedCells, with: UITableViewRowAnimation.automatic)
                weakSelf.tableView.insertRows(at: indexesOfAddedCells, with: UITableViewRowAnimation.automatic)
                weakSelf.tableView.endUpdates()
                
            } else {
                weakSelf.tableView.reloadData()
            }
        }
    }
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension PaymentsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let cellTypes = self.activeCells else {
            return 0
        }
        
        let cellType = cellTypes[indexPath.row]
        
        if cellType == .alert {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Alert") as! PaymentAlertTableViewCell
            self.setupAlertCell(cell, atIndexPath: indexPath)
            return cell.desiredHeight
        }
        
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.dueDetails != nil else { return 0 }
        
        return self.activeCells?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activeCells = self.activeCells else { return UITableViewCell() }
        let cellType = activeCells[indexPath.row]
        
        switch cellType {
            
        case .summary:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentDueSummary", for: indexPath) as! PaymentDueSummaryTableViewCell
            if let dueDetails = self.dueDetails {
                cell.setup(withDueDetails: dueDetails)
            }
            return cell
            
        case .alert:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Alert", for: indexPath) as! PaymentAlertTableViewCell
            
            let indexOfAlert = indexPath.row - self.firstAlertCellIndex!
            let alertToShow = self.alerts[indexOfAlert]
            
            cell.setup(withAlert: alertToShow)
            
            return cell
            
        case .payNow:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PayNow", for: indexPath) as! PaymentPayNowTableViewCell
            if let dueDetails = self.dueDetails {
                cell.setup(withDueDetails: dueDetails)
            }
            cell.actionHandler = { [weak self] in
                self?.performSegue(withIdentifier: "MakePayment", sender: self)
            }
            
            return cell
            
        case .schedulePayment:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SchedulePayment", for: indexPath) as! PaymentScheduleTableViewCell
            if let dueDetails = self.dueDetails {
                cell.setup(withDueDetails: dueDetails)
            }
            cell.actionHandler = { [weak self] in
                self?.performSegue(withIdentifier: "SchedulePayment", sender: self)
            }

            return cell
            
        case .accountBalance:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountBalance", for: indexPath) as! PaymentAccountBalanceTableViewCell
            if let dueDetails = self.dueDetails {
                cell.setup(withDueDetails: dueDetails)
            }
            
            return cell
            
        case .autoPay:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentAction", for: indexPath) as! PaymentActionTableViewCell
            cell.titleLabel.text = NSLocalizedString("Auto Pay", comment: "")
            cell.detailLabel.text = self.autoPayEnabled ? NSLocalizedString("On", comment: "") : NSLocalizedString("Off", comment: "")

            return cell
            
        case .history:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentAction", for: indexPath) as! PaymentActionTableViewCell
            cell.titleLabel.text = NSLocalizedString("Payments history", comment: "")
            cell.detailLabel.text = nil
            
            return cell
            
        case .savedMethods:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentAction", for: indexPath) as! PaymentActionTableViewCell
            cell.titleLabel.text = NSLocalizedString("Saved payment methods", comment: "")
            cell.detailLabel.text = nil
            
            return cell
        }
    }
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension PaymentsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let activeCells = self.activeCells else { return }
        
        let cellType = activeCells[indexPath.row]
        
        switch cellType {
        case .autoPay:
            if self.autoPayEnabled {
                self.performSegue(withIdentifier: kStoryboardAutoPayEnabledSegue, sender: nil)
                
            } else {
                self.performSegue(withIdentifier: kStoryboardAutoPayDisabledSegue, sender: nil)
            }
            
        case .history:
            self.performSegue(withIdentifier: kStoryboardShowPaymentHistory, sender: nil)
            
        case .savedMethods:
            self.performSegue(withIdentifier: kStoryboardShowPaymentMethods, sender: nil)
            
        default:
            break
        }
    }
    
}

//==============================================================================
// MARK: - QLPreviewControllerDataSource
//==============================================================================

extension PaymentsViewController: QLPreviewControllerDataSource {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return (currentInvoice!.documentURL as NSURL)
    }

}
