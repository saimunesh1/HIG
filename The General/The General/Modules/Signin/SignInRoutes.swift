//
//  SignInRoutes.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/4/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class SignInRoutes {
	class func registerRoutes() {
		let navigator = ApplicationContext.shared.navigator
		
		navigator.register("pgac://termsandconditions") { url, values, context in
			let termsAndConditionsVC = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "NavigationController")
			return termsAndConditionsVC
		}

		navigator.register("pgac://login") { url, values, context in
			let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "BaseNavigationController")
			return loginVC
		}
        
        navigator.register("pgac://onboarding") { url, values, context in
            let onboardingVC =  UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "InitialOnboardingVC")
            return onboardingVC
        }
	}
}
