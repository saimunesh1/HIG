//
//  BiometryCell.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 12/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol BiometryCellDelegate: class {
    func biometryWasEnabled()
}

class BiometryCell: UITableViewCell {
    
    enum DisplayType {
        case face
        case fingerprint
    }
    
    weak var delegate: BiometryCellDelegate?
    
    //MARK: - Interface
    func setup(withDisplayType type: BiometryCell.DisplayType) {
        
        switch type {
        case .face:
            authenticationDescription = kFaceDescription
            enableButtonDescription = kFaceEnableButtonDescription
            
        case .fingerprint:
            authenticationDescription = kFingerprintDescription
            enableButtonDescription = kFingerprintEnableButtonDescription
        }
    }
    
    fileprivate var authenticationDescription: String! {
        didSet {
            self.updateView()
        }
    }
    
    var enableButtonDescription: String! {
        didSet {
            self.updateView()
        }
    }
    
    
    //MARK: - Private
    lazy var kFaceDescription = NSLocalizedString("biometry.cell.facedescription", comment: "")
    
    lazy var kFingerprintDescription = NSLocalizedString("biometry.cell.fingerprintdescription", comment: "")
    
    lazy var kFaceEnableButtonDescription = "Enable face ID"
    
    lazy var kFingerprintEnableButtonDescription = "Enable touch ID"
    
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var enableButton: UIButton!
    
    fileprivate func updateView() {
        self.descriptionLabel?.text = self.authenticationDescription
        self.enableButton?.setTitle(self.enableButtonDescription, for: .normal)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.updateView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.updateView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateBiometricView()
        self.updateView()
    }

    fileprivate func updateBiometricView() {
        let authenticationType = ApplicationContext.shared.biometricManager.typeAvailable
        switch authenticationType {
            
        case .face:
            self.setup(withDisplayType: .face)
            
        case .fingerprint:
            self.setup(withDisplayType: .fingerprint)
            
        default:
            break
        }
    }
    
    var termsAgreement: ((_ userAgreed: Bool)->())?
    fileprivate func showBiometricAuthenticationTerms(finished: @escaping (_ userAgreed: Bool) -> ()) {
        
        termsAgreement = finished
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        let navigationController = ApplicationContext.shared.navigator.present("pgac://termsandconditions", context: nil, wrap: nil, from: rootViewController, animated: true, completion: nil) as! UINavigationController
        let termsViewController = navigationController.viewControllers.first as! TermsAndConditionsVC
        termsViewController.delegate = self
        
        switch ApplicationContext.shared.biometricManager.typeAvailable {
        case .face:
            termsViewController.mode = .faceId
        case .fingerprint:
            termsViewController.mode = .touchId
        default:
            termsViewController.mode = .touchId
        }
    }
}


// MARK: User Actions
extension BiometryCell {
    @IBAction func enableBiometricSelected(_ sender: Any) {
        self.showBiometricAuthenticationTerms { userAgreed in
            
            if userAgreed {
                
                // Identify current user is primary user
                ApplicationContext.shared.biometricManager.authenticate(reason: "Authentication", success: {
                    
                    SettingsManager.biometryEnabled = true
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.updateView()
                        self?.delegate?.biometryWasEnabled()
                    }
                })
            }
        }
    }
}


// MARK: - Terms & Conditions Delegate
extension BiometryCell: TermsAndConditionsVCDelegate {
    
    func termsAndConditionsDidPressCancel(_ viewController: TermsAndConditionsVC) {
        viewController.dismiss(animated: true, completion: nil)
        
        if let termsAgreement = self.termsAgreement {
            termsAgreement(false)
        }
    }
    
    func termsAndConditionsDidPressIAgree(_ viewController: TermsAndConditionsVC) {
        viewController.dismiss(animated: true, completion: nil)
        
        if let termsAgreement = self.termsAgreement {
            termsAgreement(true)
        }
    }
}
