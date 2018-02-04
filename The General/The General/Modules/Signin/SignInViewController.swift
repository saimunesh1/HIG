//
//  SignInViewController.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 11/21/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class SignInViewController: StretchyFooterViewController, UIValidationDelegate {

    @IBOutlet weak var socialLinksHeight: NSLayoutConstraint!
    @IBOutlet weak var rememberMeButton: YesNoSegmentControl!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var usernameValidationLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!

    let formValidator = FormErrorValidator()
    let signInService = SignInServiceConsumer()
    var oauthController: OAuthController!
    
    private func hideSocialLinks() {
        self.socialLinksHeight.constant = CGFloat(0)
    }
    
    private func showSocialLinks() {
        self.socialLinksHeight.constant = CGFloat(160)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.oauthController = OAuthController(parentViewController: self)
        
        let missingPasswordMessage = NSLocalizedString("Password is missing", comment: "")
        let missingUsernameMessage = NSLocalizedString("Invalid email or policy number", comment: "")
            
        formValidator.registerField(self.usernameField, errorLabel: self.usernameValidationLabel, rules:
            [OrRule([EmailRule(), PolicyNumberRule(), QuoteNumberRule()], message: missingUsernameMessage) ])
        formValidator.registerField(self.passwordField, errorLabel: self.passwordValidationLabel, rules: [RequiredRule(message: missingPasswordMessage)])
        
        // load username from session manager
        if let username = SessionManager.username, SettingsManager.rememberUsername {
            self.usernameField.text = username
            self.rememberMeButton.value = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.showNavigationBarShadow()
        if SettingsManager.hasLoggedInAtLeastOnce {
            self.showSocialLinks()
        } else {
            self.hideSocialLinks()
        }
    }
    
    @IBAction func didTouchFacebook(_ sender: Any) {
        self.oauthController.facebookSignIn() { [weak self] success in
            if success {
                AnalyticsManager.track(event: .signInFacebook)
                PreferencesManager.loggedInWithFb = success
                self?.presentDashboard()
            }
        }
    }

    @IBAction func didTouchGoogle(_ sender: Any) {
        self.oauthController.googleSignIn() { [weak self] success in
            if success {
                AnalyticsManager.track(event: .signInGoogle)
                PreferencesManager.loggedInWithGoogle = success
                self?.presentDashboard()
            }
        }
    }
    
    @IBAction func didTouchSignIn(_ sender: Any) {
        formValidator.validate(self)
    }

	func validationSuccessful() {
        LoadingView.show()
		
		let usernameTrimmed = self.usernameField.text?.trimmingCharacters(in: .whitespaces)
		let passwordTrimmed = self.passwordField.text?.trimmingCharacters(in: .whitespaces)
		
        try? ApplicationContext.shared.signInManager.signIn(username: usernameTrimmed, password: passwordTrimmed, success: { [weak self] in
            guard let weakSelf = self else { return }
            
            LoadingView.hide()
            SettingsManager.hasLoggedInAtLeastOnce = true

			if weakSelf.rememberMeButton.value {
                SettingsManager.rememberUsername = true
            }
			if SettingsManager.hasAgreedToTermsAndConditions {
				weakSelf.presentDashboard()
			} else {
				weakSelf.presentTermsAndConditions()
			}
		}) { [weak self] message in
            LoadingView.hide()
            self?.alert("Oops!", message: message)
        }
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)]) {
        //
    }
    
    func presentDashboard() {
        ApplicationContext.shared.navigator.replace("pgac://dashboard", context: nil, wrap: nil, handleDrawerController: false)
    }
	
	private func presentTermsAndConditions() {
		let navController = ApplicationContext.shared.navigator.present("pgac://termsandconditions", context: nil, wrap: nil, from: self.navigationController, animated: true, completion: nil) as! UINavigationController
		let termsAndConditionsVC = navController.viewControllers.first as! TermsAndConditionsVC
		termsAndConditionsVC.delegate = self
	}

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension SignInViewController: TermsAndConditionsVCDelegate {
	
	func termsAndConditionsDidPressCancel(_ viewController: TermsAndConditionsVC) {
		dismiss(animated: true, completion: nil)
	}

	func termsAndConditionsDidPressIAgree(_ viewController: TermsAndConditionsVC) {
		SettingsManager.hasAgreedToTermsAndConditions = true
		dismiss(animated: true) { [weak self] in
			self?.presentDashboard()
		}
	}
}
