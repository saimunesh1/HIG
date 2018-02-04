//
//  Biometric.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 12/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case face
    case fingerprint
    case none
}

class BiometricManager {
    
    // MARK: - Interface
    
    // ****
    // Authentication availablity
    //
    open var typeAvailable: BiometricType {
        get {
            
            if #available(iOS 11.0, *) {
                
                switch context.biometryType {
                case .faceID:
                    return .face
                case .touchID:
                    return .fingerprint
                case .none:
                    return .none
                }
                
            } else {
                
                // Previous versions to iOS 11.0 only support fingerprint
                
                var error: NSError?
                let kDesiredPolicy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
                
                let canEvaluatePolicy = context.canEvaluatePolicy(kDesiredPolicy, error: &error)
                guard canEvaluatePolicy else {
                    return .none
                }
                return .fingerprint
            }
        }
    }
    
    // ****
    // Call to authenticate
    //
    // Discussion: If success, do not require entry of username & password. If failure, proceed with normal login proceedure asking for username & password
    //
    open func authenticate(reason: String? = nil, success: @escaping () -> (), failure: (()->())? = nil) {
        
        context.localizedFallbackTitle = "Use Passcode"
        
        var error: NSError?
        let kDesiredPolicy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
        let reasonForAuthentication:String = reason ?? "Secure Login"
        
        let evaluationAvailable = context.canEvaluatePolicy(kDesiredPolicy, error: &error)
        
        guard evaluationAvailable else {
            failure?()
            return
        }
        
        context.evaluatePolicy(kDesiredPolicy, localizedReason: reasonForAuthentication, reply: { (policySuccess, error) in
            
            guard policySuccess && error == nil else {
                failure?()
                return
            }
            
            AnalyticsManager.track(event: .signInTouchID)
            success()
        })
    }
    
    
    // MARK: - Private
    fileprivate lazy var context = LAContext()
}
