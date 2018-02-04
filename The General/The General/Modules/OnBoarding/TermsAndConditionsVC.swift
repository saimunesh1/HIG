//
//  TermsAndConditionsVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/4/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol TermsAndConditionsVCDelegate: class {
	func termsAndConditionsDidPressCancel(_ viewController: TermsAndConditionsVC)
	func termsAndConditionsDidPressIAgree(_ viewController: TermsAndConditionsVC)
}

class TermsAndConditionsVC: UIViewController {
    
    // MARK: Interface
    
    enum Mode {
        case normal
        case touchId
        case faceId
    }
    
    public var mode: Mode = .normal {
        didSet(newMode) {
            self.update(withMode: newMode)
        }
    }
    
    weak public var delegate: TermsAndConditionsVCDelegate?
    
    // MARK: Private
	
	@IBOutlet fileprivate weak var cancelBarButtonItem: UIBarButtonItem!
	@IBOutlet fileprivate weak var agreeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var termsTextView: UITextView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		formatBarButtonItem(barButtonItem: cancelBarButtonItem)
		formatBarButtonItem(barButtonItem: agreeBarButtonItem)
        
        self.update(withMode: self.mode)
    }
    
    fileprivate func update(withMode mode: Mode) {
        
        switch mode {
        case .normal:
            self.navigationItem.title = NSLocalizedString("terms.normal.title", comment: "")
            // TODO: Update with App-wide terms
            
        case .touchId:
            self.navigationItem.title = NSLocalizedString("terms.touchid.title", comment: "")
            self.termsTextView.text = NSLocalizedString("terms.touchid.biometrictext", comment: "")
            
        case .faceId:
            self.navigationItem.title = NSLocalizedString("terms.faceid.title", comment: "")
             self.termsTextView.text = NSLocalizedString("terms.touchid.biometrictext", comment: "")
        }
    }
	
	private func formatBarButtonItem(barButtonItem: UIBarButtonItem) {
		barButtonItem.setTitleTextAttributes([
			NSAttributedStringKey.font: UIFont(name: "Open Sans", size: 16)!,
			NSAttributedStringKey.foregroundColor: UIColor.tgGreen,
			], for: .normal)
	}

	@IBAction func didPressCancel(_ sender: Any) {
		delegate?.termsAndConditionsDidPressCancel(self)
	}
	
	@IBAction func didPressIAgree(_ sender: Any) {
		delegate?.termsAndConditionsDidPressIAgree(self)
	}
}
