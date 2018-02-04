//
//  PreLoginViewController.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 11/21/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import SafariServices
import Nuke

class PreSignInViewController: UIViewController {
    
    @IBOutlet weak var socialLinksHeight: NSLayoutConstraint!
    
    @IBOutlet weak var getAQuoteImageView: UIImageView!
    @IBOutlet weak var idCardsImageView: UIImageView!
    @IBOutlet weak var supportImageView: UIImageView!
    @IBOutlet weak var promoImageView: UIImageView!

    @IBOutlet weak var signInWithEmailButton: CustomButton!

    @IBOutlet weak var signInWithLabel: UILabel!
    @IBOutlet weak var signInWithFacebookLabel: UILabel!
    @IBOutlet weak var signInWithGoogleLabel: UILabel!
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var idCardsLabel: UILabel!
    @IBOutlet weak var getAQuoteLabel: UILabel!
    @IBOutlet weak var supportLabel: UILabel!
    
    var oauthController: OAuthController!

    private func hideSocialLinks() {
        self.socialLinksHeight.constant = CGFloat(0)
    }
    
    private func showSocialLinks() {
        self.socialLinksHeight.constant = CGFloat(90)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.oauthController = OAuthController(parentViewController: self)

        self.idCardsImageView.tintColor = UIColor.tgGreen
        self.supportImageView.tintColor = UIColor.tgGreen
        self.getAQuoteImageView.tintColor = UIColor.tgGreen
		
		view.superview?.layoutIfNeeded()
		if view.frame.size.width <= 320.0 {
			signInWithEmailButton.titleLabel?.font = UIFont.alert
		}
        
        biometricSignInIfAvailable()
        
        setupPromo()
    }
    
    private func setupPromo() {
        ApplicationContext.shared.dashboardManager.getPromo(completion: { [weak self] (innerClosure) in
            _ = try? innerClosure()
            
            if let imageUrl = DashboardManager.promo?.imageUrl, let url = URL(string: imageUrl) {
                Nuke.Manager.shared.loadImage(with: url, completion: { [weak self] image in
                    self?.promoImageView.image = image.value
                })
            } else {
                self?.promoImageView.image = nil
            }
        })
    }
    
    private func biometricSignInIfAvailable() {
        
        guard SettingsManager.biometryEnabled else {
            return
        }
        
        ApplicationContext.shared.biometricManager.authenticate(reason: "Sign In", success: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                
                LoadingView.show(inView: strongSelf.view, type: .hud, displayText: "Signing in...", animated: true)
                
                do {
                    try ApplicationContext.shared.signInManager.signIn(success: { [weak self] in
                        
                        guard let strongSelf = self else {
                            return
                        }
                        
                        LoadingView.hide(inView: strongSelf.view, animated: true)
                        
                        if SettingsManager.hasAgreedToTermsAndConditions {
                            self?.presentDashboard()
                        } else {
                            self?.presentTermsAndConditions()
                        }
                        
                        }, failure: { message in
                            
                            LoadingView.hide()
                    })
                    
                } catch {
                    LoadingView.hide()
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)

        if SettingsManager.hasLoggedInAtLeastOnce {
            self.showSocialLinks()
        } else {
            self.hideSocialLinks()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
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
	
	@IBAction func didTouchCreateAccount(_ sender: Any) {
		if let createAccountUrlString = ApplicationContext.shared.signInManager.createAccountUrlString() {
			guard let url = URL.init(string: createAccountUrlString) else { return }
			let safariViewController = SFSafariViewController(url: url)
			safariViewController.delegate = self
			// Using this method because it doesn't work otherwise when signed in (https://forums.developer.apple.com/thread/62012)
			guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
			rootViewController.present(safariViewController, animated: true, completion: nil)
		}
	}
    
    @IBAction func didPressIDCards(_ sender: Any) {
        if IDCardManager.isCardIDInfoCached {
            let vc = UIStoryboard(name: "IDCards", bundle: nil).instantiateViewController(withIdentifier: "IDCardsVC") as! IDCardsVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
	@IBAction func didPressGetAQuote(_ sender: Any) {
		ApplicationContext.shared.navigator.push("pgac://quotes/getaquote", context: nil, from: nil, animated: true)
	}
	
	@IBAction func didPressSupport(_ sender: Any) {
		ApplicationContext.shared.navigator.push("pgac://support", context: nil, from: nil, animated: true)
	}
	
    func presentDashboard() {
        ApplicationContext.shared.navigator.replace("pgac://dashboard", context: nil, wrap: nil, handleDrawerController: false)
    }
    
    private func presentTermsAndConditions() {
        let navController = ApplicationContext.shared.navigator.present("pgac://termsandconditions", context: nil, wrap: nil, from: self.navigationController, animated: true, completion: nil) as! UINavigationController
        let termsAndConditionsVC = navController.viewControllers.first as! TermsAndConditionsVC
        termsAndConditionsVC.delegate = self
    }

}

extension PreSignInViewController: TermsAndConditionsVCDelegate {
    
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

extension PreSignInViewController: SFSafariViewControllerDelegate {
	
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
	
}
