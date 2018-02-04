//
//  PolicyRoutes.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PolicyRoutes {
    
    class func registerRoutes() {
        let navigator = ApplicationContext.shared.navigator
        
        navigator.register("pgac://policy") { url, values, context in
            let policyVC = UIStoryboard(name: "Policy", bundle: nil).instantiateViewController(withIdentifier: "PolicyFullTableVC")
            return policyVC
        }

        navigator.register("pgac://policy/history") { url, values, context in
            return UIStoryboard(name: "Policy-History", bundle: nil).instantiateInitialViewController()
        }
    }
}
