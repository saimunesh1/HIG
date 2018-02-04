//
//  AlphaRule.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/9/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public class AlphaRule: CharacterSetRule {
    
    public init(message: String = NSLocalizedString("error.handling.alpha", comment: "")) {
        super.init(characterSet: CharacterSet.letters, message: message)
    }
}
