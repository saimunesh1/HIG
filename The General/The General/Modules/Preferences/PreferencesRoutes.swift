//
//  PreferencesRoutes.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PreferencesRoutes {
    class func registerRoutes() {
        let navigator = ApplicationContext.shared.navigator
        
        navigator.register("pgac://preferences") { url, values, context in
            let prefVC = UIStoryboard(name: "Preferences", bundle: nil).instantiateViewController(withIdentifier: "PreferencesTableVC")
            return prefVC
        }
    }
}
