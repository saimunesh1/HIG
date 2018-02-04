//
//  AutoPayCancel.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 1/18/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

protocol AutoPayCancelManagerProtocol {
    func viewIsReady()
    func userChoseToDiscontinueAutopay()
    func userChoseToExit()
}

extension AutoPayCancelManager: AutoPayCancelManagerProtocol {
    
    func viewIsReady() {
        // No action needed
    }
    
    func userChoseToDiscontinueAutopay() {
        
        guard let policyNumber = SessionManager.policyNumber else {
            return
        }
        
        self.view.showLoading()
        
        let succeeded: ()->() = { [weak self] in
            self?.view.showSuccess(doneShowing: {
                self?.view.dismiss(autopayCancelled: true)
            })
        }
        
        let failed: ()->() = { [weak self] in
            self?.view.hideLoading()
            self?.view.showCouldNotUnregisterAutopay()
        }
        
        do {
            try self.service.unregister(forPolicyNumber: policyNumber) { success in
                
                if success {
                    succeeded()
                } else {
                    failed()
                }
            }
        } catch {
            failed()
        }
    }
    
    func userChoseToExit() {
        self.view.dismiss(autopayCancelled: false)
    }
}

class AutoPayCancelManager {
    
    lazy var service = AutoPayService()
    
    init(view: AutoPayCancelViewProtocol) {
        self.view = view
    }
    
    private unowned var view: AutoPayCancelViewProtocol
    
}

protocol AutoPayCancelViewProtocol: class {
    func showLoading()
    func showSuccess(doneShowing: (() -> ())?)
    func hideLoading()
    func showCouldNotUnregisterAutopay()
    func dismiss(autopayCancelled: Bool)
}

extension AutoPayCancelViewController: AutoPayCancelViewProtocol {
    func showLoading() {
        LoadingView.show(inView: self.view, type: .hud, displayText: "Cancelling...", animated: true)
    }
    
    func showSuccess(doneShowing: (() -> ())?) {
        LoadingView.showComplete(animated: true, inView: self.view, finished: doneShowing)
    }
    
    func hideLoading() {
        LoadingView.hide(inView: self.view, animated: true)
    }
    
    func showCouldNotUnregisterAutopay() {
        let alert = UIAlertController(title: NSLocalizedString("alert.title", comment: ""), message: NSLocalizedString("payments.autopay.couldnotdeactivate.message", comment: ""), preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: NSLocalizedString("alert.ok", comment: ""), style: .cancel) { (action) in
            // No action, so user can try again if needed
        }
        
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func dismiss(autopayCancelled: Bool) {
        
        self.dismiss(animated: true, completion: nil)
        
        guard autopayCancelled else {
            return
        }
        
        if let paymentsNavigationController = ApplicationContext.shared.navigator.replace("pgac://payments", context: nil, wrap: BaseNavigationController.self) as? UINavigationController, let paymentsViewController = paymentsNavigationController.viewControllers.first {
            
            paymentsViewController.performSegue(withIdentifier: "Show Auto Pay Disabled", sender: self)
        }
    }
}

class AutoPayCancelViewController: UIViewController {
    
    private lazy var manager = AutoPayCancelManager(view: self) as AutoPayCancelManagerProtocol
    
    @IBAction func discardAction(_ sender: UIBarButtonItem) {
        self.manager.userChoseToExit()
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.manager.userChoseToDiscontinueAutopay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.manager.viewIsReady()
    }
}
