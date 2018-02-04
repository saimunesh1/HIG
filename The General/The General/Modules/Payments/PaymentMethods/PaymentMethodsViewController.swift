//
//  PaymentMethodsViewController.swift
//  The General
//
//  Created by Derek Bowen on 10/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import SafariServices

class PaymentMethodsViewController: UIViewController {
    
    //--------------------------------------------------------------------------
    // MARK: - Interface
    //--------------------------------------------------------------------------
    
    enum CashMode {
        case cashEnabled
        case cashDisabled
    }
    
    enum PaymentMode {
        case selectingForPayment
        case editing
    }
    
    /// Indicates whether cash selection is enabled or disabled
    var cashMode: CashMode = .cashEnabled
    
    /// 'selectingForPaymentng' indicates we're coming from the make payment screen
    var paymentMode: PaymentMode = .selectingForPayment

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateContainerView: UIView!
    @IBOutlet weak var addPaymentMethodButton: UIButton!
    
    /// Callback for when a payment method is selected
    var paymentMethodSelectedHandler: ((PaymentMethodResponse) -> Void)?
    
    /// Active make payment session
    var paymentSession: MakePaymentSession? {
        get {
            return ApplicationContext.shared.paymentsManager.activeMakePaymentSession
        }
    }
    
    /// Saved payment methods on the user's account
    var paymentMethods: [PaymentMethodResponse]?
    
    /// Due details about the user's policy
    var dueDetails: PaymentsGetDueDetailsResponse? = ApplicationContext.shared.paymentsManager.dueDetails

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        // Default state is "undetermined" -> hide all content until we make
        // the service call
        tableView.isHidden = true
        emptyStateContainerView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchPaymentMethods()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Segue Handling
    //--------------------------------------------------------------------------

    @IBAction func goBack(segue: UIStoryboardSegue) { }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    var sections: [Section] {
        get {
            var sections: [Section] = []
            sections.append(.mainPaymentMethods)
            
            if self.cashMode == .cashEnabled && self.paymentMode != .editing {
                sections.append(.cashPayment)
            }
            return sections
        }
    }
    
    enum Section {
        case mainPaymentMethods
        case cashPayment
    }

    private func fetchPaymentMethods() {
        LoadingView.show(inView: self.view, type: .hud, animated: true)
        ApplicationContext.shared.paymentsManager.getSavedPaymentMethods(forPolicy: SessionManager.policyNumber ?? "") { [weak self] (innerClosure) in
            guard let weakSelf = self else { return }
            LoadingView.hide(inView: weakSelf.view, animated: true)

            do {
                let paymentMethods = try innerClosure()
                weakSelf.paymentMethods = paymentMethods.sorted(by: { (paymentMethod, _) -> Bool in
                    return paymentMethod.preferred
                })
                weakSelf.updateView()
            }
            catch {
                weakSelf.updateView()

                // TODO: Better error handling
                let alert = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
                    self?.dismiss(animated: true, completion: nil)
                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private var paymentMethodsCount: Int {
        get {
            var paymentMethodsCount = self.paymentMethods?.count ?? 0
            if self.paymentMode == .selectingForPayment {
                paymentMethodsCount += self.paymentSession?.temporaryPaymentMethods.count ?? 0
            }
            return paymentMethodsCount
        }
    }
    
    private var paymentMethodsExist: Bool {
        get {
            return paymentMethodsCount > 0
        }
    }

    private var cashOptionShown: Bool {
        get {
            return self.paymentMode != .editing && self.cashMode == .cashEnabled
        }
    }
    
    private func updateView() {
        
        if !paymentMethodsExist && !cashOptionShown {
            emptyStateContainerView.isHidden = false
            tableView.isHidden = true
            navigationItem.rightBarButtonItem = nil
            
        } else {
            emptyStateContainerView.isHidden = true
            tableView.isHidden = false
            showAddButton()
            tableView.reloadData()
        }
    }

    private func showAddButton() {
        let addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "24px__add-circle.pdf"), style: .plain, target: self, action: #selector(addPaymentMethod))
        addButton.tintColor = UIColor.tgGreen
        navigationItem.rightBarButtonItem = addButton
    }

    private func showAddPayment(withType type: PaymentMethodType) {
        if type == .card {
            let addCreditCardVC = UIStoryboard(name: "Payments", bundle: nil).instantiateViewController(withIdentifier: "AddCreditCardViewController") as! AddCreditCardViewController
            addCreditCardVC.dueDetails = self.dueDetails
            addCreditCardVC.showSaveControl = self.paymentMode == .selectingForPayment
            navigationController?.pushViewController(addCreditCardVC, animated: true)
        }
        else {
            let addBankAccountVC = UIStoryboard(name: "Payments", bundle: nil).instantiateViewController(withIdentifier: "AddBankAccountViewController") as! AddBankAccountViewController
            addBankAccountVC.dueDetails = self.dueDetails
            addBankAccountVC.showSaveControl = self.paymentMode == .selectingForPayment
            navigationController?.pushViewController(addBankAccountVC, animated: true)
        }
    }

    /// Returns payment method for the given row
    ///
    /// - Parameter row: Row in tableview
    /// - Returns: PaymentMethodResponse
    private func paymentMethod(forRow row: Int) -> PaymentMethodResponse? {
        let paymentMethodsCount = self.paymentMethods?.count ?? 0
        
        if row < paymentMethodsCount {
            return self.paymentMethods?[row]
        }
        else {
            return self.paymentSession?.temporaryPaymentMethods[row - paymentMethodsCount]
        }
    }
    
    
    // MARK: - Pay Near Me
    func showPayNearMeFailureMessage() {
        let alert = UIAlertController(title: NSLocalizedString("payments.paynearme.couldntload.title", comment: ""), message: NSLocalizedString("payments.paynearme.couldntload.message", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.ok", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension PaymentMethodsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerHeight: CGFloat = 30.0
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
        
		// Header background
		let backgroundView = UIView()
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.backgroundColor = .white
		headerView.addSubview(backgroundView)
		
		backgroundView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
		backgroundView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0).isActive = true
		backgroundView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
		backgroundView.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true

		// Separator line
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .tgGray
        headerView.addSubview(separatorView)
		
        separatorView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 12).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionType = self.sections[section]
        
        switch sectionType {
            
        case .mainPaymentMethods:
            return paymentMethodsCount
            
        case .cashPayment:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethod", for: indexPath) as! PaymentMethodTableViewCell
        
        let sectionType = self.sections[indexPath.section]
        
        switch sectionType {
        case .mainPaymentMethods:
            if let paymentMethod = self.paymentMethod(forRow: indexPath.row) {
                cell.setup(withPaymentMethod: paymentMethod)
                
                cell.checkmarkImageView.isHidden = true
                if let selectedPaymentMethod = self.paymentSession?.paymentEntries.first?.paymentMethod, selectedPaymentMethod == paymentMethod, paymentMode == .selectingForPayment {
                    cell.checkmarkImageView.isHidden = false
                }
            }
            
        case .cashPayment:
            cell.iconImageView.image = #imageLiteral(resourceName: "24px__cash")
            cell.titleLabel.text = NSLocalizedString("Cash", comment: "")
            cell.detailLabel.text = NSLocalizedString("Data connection required", comment: "")
            
        }
        
        return cell
    }
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension PaymentMethodsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionType = self.sections[indexPath.section]
        
        switch sectionType {
        case .mainPaymentMethods:
            
            switch self.paymentMode {
            case .selectingForPayment:
                if let paymentMethod = self.paymentMethod(forRow: indexPath.row) {
                    let cell = tableView.cellForRow(at: indexPath) as! PaymentMethodTableViewCell
                    cell.checkmarkImageView.isHidden = false
                    tableView.reloadData()
                    
                    self.paymentMethodSelectedHandler?(paymentMethod)
                    self.navigationController?.popViewController(animated: true)
                }
                
            case .editing:
                if let paymentMethod = self.paymentMethod(forRow: indexPath.row) {
                    if paymentMethod.type == .card {
                        let vc = UIStoryboard(name: "Payments", bundle: nil).instantiateViewController(withIdentifier: "EditCreditCardViewController") as! EditCreditCardViewController
                        vc.paymentMethod = paymentMethod
                        navigationController?.pushViewController(vc, animated: true)
                    }
                    else {
                        let vc = UIStoryboard(name: "Payments", bundle: nil).instantiateViewController(withIdentifier: "EditBankAccountViewController") as! EditBankAccountViewController
                        vc.paymentMethod = paymentMethod
                        navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            
        case .cashPayment:
            guard let paymentAmount = self.dueDetails?.minimumPayment, let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                self.showPayNearMeFailureMessage()
                return
            }
            
            LoadingView.show(type: .hud, withDisplayText: "Please wait...", animated: true)
            
            PayNearMe.activate(withAmount: paymentAmount.rawValue, complete: { (url, issue) in
                
                LoadingView.hide()
                
                if let url = url {
                    let safariViewController = SFSafariViewController(url: url)
                    safariViewController.delegate = self
                    rootViewController.present(safariViewController, animated: true, completion: nil)
                    
                } else {
                    self.showPayNearMeFailureMessage()
                }
            })
        }
    }
}

//==============================================================================
// MARK: - Webview Delegate
//==============================================================================

extension PaymentMethodsViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            controller.dismiss(animated: true, completion: {
                
                self.showPayNearMeFailureMessage()
            })
        }
    }
}

//==============================================================================
// MARK: - Actions
//==============================================================================

extension PaymentMethodsViewController {

    @IBAction func addPaymentMethod(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("payments.action.add", comment: ""), message: nil, preferredStyle: .actionSheet)

        let addCard = UIAlertAction(title: NSLocalizedString("payments.action.add.creditcard", comment: ""), style: .default) { [weak self] (action) in
            self?.showAddPayment(withType: .card)
        }
        alert.addAction(addCard)

        let addAccount = UIAlertAction(title: NSLocalizedString("payments.action.add.bankaccount", comment: ""), style: .default) { [weak self] (action) in
            self?.showAddPayment(withType: .bankAccount)
        }
        alert.addAction(addAccount)

        let cancel = UIAlertAction(title: NSLocalizedString("alert.cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
