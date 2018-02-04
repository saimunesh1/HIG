//
//  LoginRouteTemp.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class LoginRouteTemp {
	class func registerRoutes() {
		let navigator = ApplicationContext.shared.navigator
		
		navigator.register("pgac://home") { url, values, context in
			let paymentsVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "BaseNavigationController")
			return paymentsVC
		}
	}
}
