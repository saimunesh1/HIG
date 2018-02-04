//
//  ClaimsRoutes.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/12/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsRoutes {
	
	class func registerRoutes() {
		let navigator = ApplicationContext.shared.navigator
		
		navigator.register("pgac://claims") { url, values, context in
			let claimsVC = UIStoryboard(name: "Claims", bundle: nil).instantiateViewController(withIdentifier: "ClaimsDashboardVC")
			return claimsVC
		}
	}
}
