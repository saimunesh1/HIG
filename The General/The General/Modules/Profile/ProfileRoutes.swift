//
//  ProfileRoutes.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/21/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ProfileRoutes {
    class func registerRoutes() {
        let navigator = ApplicationContext.shared.navigator
        
        navigator.register("pgac://profile") { url, values, context in
            let profileVC = UIStoryboard(name: "User-Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableVC")
            return profileVC
        }
    }

}
