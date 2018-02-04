//
//  ForgotPasswordViewController.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 11/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: StretchyFooterViewController, UIValidationDelegate, UITextFieldDelegate {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var usernameValidationLabel: UILabel!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    let formValidator = FormErrorValidator()
    let signInService = SignInServiceConsumer()

    override func viewDidLoad() {
        super.viewDidLoad()

        let missingUsernameMessage = NSLocalizedString("Invalid email or policy number", comment: "")
        formValidator.registerField(self.usernameField, errorLabel: self.usernameValidationLabel, rules:
            [OrRule([EmailRule(), PolicyNumberRule()], message: missingUsernameMessage) ])

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.showNavigationBarShadow()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.hideNavigationBarShadow()
    }

    @IBAction func didTouchSend(_ sender: Any) {
        formValidator.validate(self)
    }

    @IBAction func usernameFieldChanged(_ sender: Any) {
        let username = self.usernameField.text ?? ""
        self.sendButton.isEnabled = !username.isEmpty
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        formValidator.validate(self)
        
        return false
    }

    func validationSuccessful() {
        let username = self.usernameField.text ?? ""
        
        LoadingView.show(inView: self.view, type: .hud, animated: true)
        signInService.requestPasswordReset(emailOrPolicy: username) {[weak self] (innerClosure) in
            guard let weakSelf = self else { return }
            LoadingView.hide(inView: weakSelf.view, animated: true)
            
            do {
                try innerClosure()
                
                weakSelf.navigationController?.popViewController(animated: true)
            }
            catch ServiceErrorType.unsuccessful {
                let badLoginError = NSLocalizedString("Unrecognized policy number or email", comment: "")
                weakSelf.alert("Oops!", message: badLoginError)
            }
            catch let error {
                weakSelf.alert("Oops!", message: error.localizedDescription)
            }
        }
        
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)]) {
        
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
