//
//  SupportRoutes.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class SupportRoutes {
	class func registerRoutes() {
		let navigator = ApplicationContext.shared.navigator
		
		navigator.register("pgac://about") { url, values, context in
			let supportVC = UIStoryboard(name: "Support", bundle: nil).instantiateViewController(withIdentifier: "SupportAboutVC")
			return supportVC
		}
		
		navigator.register("pgac://support") { url, values, context in
			let supportVC = UIStoryboard(name: "Support", bundle: nil).instantiateViewController(withIdentifier: "SupportVC")
			return supportVC
		}
	}
}
