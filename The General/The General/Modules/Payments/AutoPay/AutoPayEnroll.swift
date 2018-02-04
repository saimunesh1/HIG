//
//  AutoPayEnroll.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 1/17/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - Manager
//--------------------------------------------------------------------------

protocol AutoPayEnrollManagerProtocol {
    func viewHasLoaded()
    func requestPaymentMethod() -> PaymentMethodResponse?
    func userSelectedPaymentMethod(_ paymentMethod: PaymentMethodResponse)
    func userChoseToEnroll()
}

//MARK: - View to Manager
extension AutoPayEnrollManager: AutoPayEnrollManagerProtocol {
    
    func viewHasLoaded() {
        // No action
    }
    
    func requestPaymentMethod() -> PaymentMethodResponse? {
        return self.paymentMethod
    }
    
    func userSelectedPaymentMethod(_ paymentMethod: PaymentMethodResponse) {
        self.paymentMethod = paymentMethod
        self.view.showPaymentSelected()
    }
    
    func userChoseToEnroll() {
        
        guard let paymentSelected = self.paymentMethod else {
            return
        }
        
        self.enroll(withPaymentMethod: paymentSelected)
    }
}

class AutoPayEnrollManager {
    
    /**
     Initialize manager with an object capable of receiving view-related calls.
     - Parameters:
        - view: AutoPayEnrollViewProtocol item.
     */
    init(view: AutoPayEnrollViewProtocol) {
        self.view = view
    }
    
    
    //MARK: - Private
    private var paymentMethod: PaymentMethodResponse?
    
    private func enroll(withPaymentMethod paymentMethod: PaymentMethodResponse) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            return // Always fail silently if policy number doesn't get through (very improbable)
        }
        
        self.view.showLoading()
        
        let successful: ()->() = { [weak self] in
            
            LoadingView.showComplete {
                self?.navigateToEnrollmentStatus()
            }
        }
        
        let failed: ()->() = { [weak self] in
            self?.view.hideLoading()
            self?.view.showCouldNotEnroll()
        }
        
        do {
            try service.enroll(usingPayment: paymentMethod, forPolicyNumber: policyNumber, completion: { success in
                
                guard success else {
                    failed()
                    return
                }
                
                successful()
            })
            
        } catch {
            failed()
        }
    }
    
    private func navigateToEnrollmentStatus() {
        self.view.navigateToEnrollmentStatus()
    }
    
    private lazy var service = AutoPayService()
    
    unowned private var view: AutoPayEnrollViewProtocol
}

//--------------------------------------------------------------------------
// MARK: - View Controller
//--------------------------------------------------------------------------

protocol AutoPayEnrollViewProtocol: class {
    func showPaymentSelected()
    func showLoading()
    func hideLoading()
    func showComplete(doneShowing: (() -> ())?)
    func showCouldNotEnroll()
    func navigateToEnrollmentStatus()
    func enableEnroll()
    func disableEnroll()
}

//MARK: - Manager to View
extension AutoPayEnrollViewController: AutoPayEnrollViewProtocol {
    
    func showPaymentSelected() {
        self.updateView()
    }
    
    func showLoading() {
        LoadingView.show(type: .hud, withDisplayText: "Enrolling...", animated: true)
    }
    
    func hideLoading() {
        LoadingView.hide()
    }
    
    func showComplete(doneShowing: (() -> ())?) {
        LoadingView.showComplete {
            doneShowing?()
        }
    }
    
    func showCouldNotEnroll() {
        let alert = UIAlertController(title: NSLocalizedString("alert.title", comment: ""), message: NSLocalizedString("payments.autopay.couldnotenroll.message", comment: ""), preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: NSLocalizedString("alert.ok", comment: ""), style: .cancel) { (action) in
            // No action, so user can try again if needed
        }
        
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func navigateToEnrollmentStatus() {
        self.performSegue(withIdentifier: "Show Enrollment Status", sender: self)
    }
    
    func disableEnroll() {
        self.enrollButton.isEnabled = false
    }
    
    func enableEnroll() {
        self.enrollButton.isEnabled = true
    }
}

class AutoPayEnrollViewController: UIViewController {
    
    
    //MARK: - Private
    lazy private var manager = AutoPayEnrollManager(view: self) as AutoPayEnrollManagerProtocol
    
    private var paymentMethodSelected: PaymentMethodResponse? {
        get {
            return self.manager.requestPaymentMethod()
        }
    }
    
    static private let kPaymentDescriptionPlaceholder = NSLocalizedString("payments.ui.paymentselectedplaceholder", comment: "")
    
    override internal func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Select Payment Method" {
            
            let destinationViewController = segue.destination as! PaymentMethodsViewController
            destinationViewController.cashMode = .cashDisabled
            destinationViewController.paymentMethodSelectedHandler = { [weak self] paymentSelected in
                
                self?.manager.userSelectedPaymentMethod(paymentSelected)
            }
        }
    }
    
    
    //MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInitialState()
        
        self.manager.viewHasLoaded()
    }
    
    @IBOutlet weak var bankAccountDisclaimerZeroHeightConstraint: NSLayoutConstraint!
    
    private func updateView() {
        
        guard let paymentSelected = self.paymentMethodSelected else {
            enrollButton.isEnabled = false
            return
        }
        
        self.paymentMethodLabel.text = paymentSelected.displayName
        self.enrollButton.isEnabled = true
        
        func showBankAccountDisclaimer(_ show: Bool) {
            bankAccountDisclaimerZeroHeightConstraint.priority = UILayoutPriority(rawValue: show ? 1 : 999)
        }
        
        showBankAccountDisclaimer(paymentSelected.type == .bankAccount)
    }
    
    private func setupInitialState() {
        self.iconView.tintColor = UIColor.tgOrange
        self.updateView()
    }
    
    
    //MARK: Outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet private weak var paymentMethodLabel: UILabel!
    @IBOutlet private weak var enrollButton: CustomButton!
    
    
    //MARK: Actions
    @IBAction private func enrollAction(_ sender: CustomButton) {
        self.manager.userChoseToEnroll()
    }
}
