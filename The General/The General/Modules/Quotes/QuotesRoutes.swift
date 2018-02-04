//
//  QuotesRoutes.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class QuotesRoutes {
	class func registerRoutes() {
		let navigator = ApplicationContext.shared.navigator
		
		navigator.register("pgac://quotes") { url, values, context in
			let paymentsVC = UIStoryboard(name: "Quotes", bundle: nil).instantiateViewController(withIdentifier: "QuotesVC")
			return paymentsVC
		}
		
		navigator.register("pgac://quotes/getaquote") { url, values, context in
			let paymentsVC = UIStoryboard(name: "Quotes", bundle: nil).instantiateViewController(withIdentifier: "GetAQuoteVC")
			return paymentsVC
		}
	}
}
