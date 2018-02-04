//
//  IDCardsRoutes.swift
//  The General
//
//  Created by Hopkinson, Todd (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class IDCardsRoutes {
    class func registerRoutes() {
        let navigator = ApplicationContext.shared.navigator
        
        navigator.register("pgac://idcards") { url, values, context in
            let supportVC = UIStoryboard(name: "IDCards", bundle: nil).instantiateViewController(withIdentifier: "IDCardsVC")
            return supportVC
        }
    }
}
