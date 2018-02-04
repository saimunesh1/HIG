//
//  SupportAboutVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/5/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit
import SafariServices

class SupportAboutVC: BaseVC {
	
	@IBOutlet weak var termsAndConditionsLabel: UILabel!
	@IBOutlet weak var privacyPolicyLabel: UILabel!
    @IBOutlet weak var licensingNoticesLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!

	private let facebookUrl = URL(string: "https://www.facebook.com/TheGeneralAuto/")!
	private let privacyPolicyUrl = URL(string: "https://www.thegeneral.com/legal/privacy-policy/")!
	private let termsAndConditionsUrl = URL(string: "https://www.thegeneral.com/legal/terms-and-conditions/")!
	private let twitterUrl = URL(string: "https://twitter.com/thegeneralauto?lang=en")!
	private let youTubeUrl = URL(string: "https://www.youtube.com/channel/UC_o7kIzb9ruXVUVMZO12Kxg")!
	private let instagramUrl = URL(string: "https://www.instagram.com/thegeneralauto/")!

	override func viewDidLoad() {
        super.viewDidLoad()
		termsAndConditionsLabel.attributedText = termsAndConditionsLabel.text?.addLinkFormattingTo(substring: "Terms and Conditions")
		privacyPolicyLabel.attributedText = privacyPolicyLabel.text?.addLinkFormattingTo(substring: "Privacy Policy")
		licensingNoticesLabel.attributedText = licensingNoticesLabel.text!.addLinkFormattingTo(substring: "Third-party Licensing Notices")
        setupVersionLabel()

        AnalyticsManager.track(event: .aboutSectionWasVisited)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		baseNavigationController?.showMenuButton()
	}
	
    private func setupVersionLabel() {
        guard let infoDictionary = Bundle.main.infoDictionary,
            let version = infoDictionary["CFBundleShortVersionString"] as? String,
            let build = infoDictionary["CFBundleVersion"] as? String
            else {
                return
        }
        
        self.versionLabel.text = "Version: \(version).\(build)"
    }
    
	private func open(url: URL) {
		if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
			let safariViewController = SFSafariViewController(url: url)
			safariViewController.delegate = self
			rootViewController.present(safariViewController, animated: true, completion: nil)
		}
	}

	@IBAction func didPressInstagram(_ sender: Any) {
		UIApplication.shared.open(instagramUrl, options: [:], completionHandler: nil)
	}
	
	@IBAction func didPressTwitter(_ sender: Any) {
		UIApplication.shared.open(twitterUrl, options: [:], completionHandler: nil)
	}
	
	@IBAction func didPressFacebook(_ sender: Any) {
		UIApplication.shared.open(facebookUrl, options: [:], completionHandler: nil)
	}
	
	@IBAction func didPressYouTube(_ sender: Any) {
		UIApplication.shared.open(youTubeUrl, options: [:], completionHandler: nil)
	}
	
	@IBAction func didPressTermsAndConditions(_ sender: Any) {
		open(url: termsAndConditionsUrl)
	}
	
	@IBAction func didPressPrivacyPolicy(_ sender: Any) {
		open(url: privacyPolicyUrl)
	}
	
	@IBAction func didPressSupport(_ sender: Any) {
		if let vc = ApplicationContext.shared.navigator.replace("pgac://support", context: nil, wrap: BaseNavigationController.self) {
			vc.baseNavigationController?.showMenuButton()
		}
	}
	
}

extension SupportAboutVC: SFSafariViewControllerDelegate {
	
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
		if !didLoadSuccessfully {
			controller.dismiss(animated: true, completion: {
				// TODO: Show alert
			})
		}
	}
	
}
