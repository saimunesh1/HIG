//
//  FNOLRoutes.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 11/29/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class FNOLRoutes {
    class func registerRoutes() {
        let navigator = ApplicationContext.shared.navigator
        
        // - Start a new claim
        navigator.register("pgac://fnol/start") { url, values, context in
            guard let policyNumber = SessionManager.policyNumber else {
                let alert = UIAlertController(title: "Error", message: "No policy associated with user.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                return alert
            }
            
            ApplicationContext.shared.fnolClaimsManager = FNOLClaimsManager()
            guard let questionnaire = ApplicationContext.shared.fnolClaimsManager.questionnaire(forPolicy: policyNumber) else {
                let alert = UIAlertController(title: "Error", message: "Unable to load questionnaire.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                return alert
            }

            ApplicationContext.shared.fnolClaimsManager.startNewClaim()
            
            return AtTheSceneHelper.atTheSceneActionSheet(forQuestionnaire: questionnaire)
        }
        
        // - Resume a claim
        navigator.register("pgac://fnol/resume/<string:fnolClaimId>") { url, values, context in
            guard let fnolClaimId = values["fnolClaimId"] as? String else { return nil }
            guard let policyNumber = SessionManager.policyNumber else {
                let alert = UIAlertController(title: "Error", message: "No policy associated with user.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                return alert
            }
            
            ApplicationContext.shared.fnolClaimsManager = FNOLClaimsManager()
            guard let questionnaire = ApplicationContext.shared.fnolClaimsManager.questionnaire(forPolicy: policyNumber) else {
                let alert = UIAlertController(title: "Error", message: "Unable to load questionnaire.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                return alert
            }
            guard let claim = FNOLClaim.mr_findFirst(byAttribute: "localId", withValue: fnolClaimId) else {
                let alert = UIAlertController(title: "Error", message: "No previous claim has been started.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                return alert
            }
            
            ApplicationContext.shared.fnolClaimsManager.resumeExistingClaim(claim)
            
            return AtTheSceneHelper.atTheSceneActionSheet(forQuestionnaire: questionnaire)
        }
        
        // - Show oboarding screen (internal)
        navigator.register("pgac://fnol/onboarding") { url, values, context in
            guard ApplicationContext.shared.fnolClaimsManager.activeClaim != nil else { return nil }
            
            return UIStoryboard(name: "FNOL", bundle: nil).instantiateViewController(withIdentifier: "FNOLOnboardingVC")
        }
    }
}
