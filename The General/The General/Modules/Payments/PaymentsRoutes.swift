//
//  PaymentsRoutes.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 11/29/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PaymentsRoutes {
    class func registerRoutes() {
        let navigator = ApplicationContext.shared.navigator
        
        navigator.register("pgac://payments") { url, values, context in
            let paymentsVC = UIStoryboard(name: "Payments", bundle: nil).instantiateViewController(withIdentifier: "BaseNavigationController")
            return paymentsVC
        }
    }
}
