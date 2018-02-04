//
//  DashboardRoutes.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 11/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class DashboardRoutes {
    class func registerRoutes() {
        let navigator = ApplicationContext.shared.navigator
        
        // Returns a new instance of the DrawerController with the default content views, if the root-view controller isn't the drawer
        // Otherwise it just returns the dashboard view itself
        navigator.register("pgac://dashboard") { url, values, context in
            guard SessionManager.accessToken != nil else { return nil }
            
            if let _ = UIApplication.shared.keyWindow?.rootViewController as? DrawerController {
                let dashboard = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "Dashboard")
                return dashboard
            }
            else {
                let drawer = UIStoryboard(name: "Dashboard", bundle: nil).instantiateInitialViewController()
                return drawer
            }
        }
        
        navigator.register("pgac://signin") { url, values, context in
            return UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "skip-pre-login")
        }

    }
}
