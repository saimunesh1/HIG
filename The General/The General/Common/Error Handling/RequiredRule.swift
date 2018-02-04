//
//  RequiredRule.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/9/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class RequiredRule: FieldRule {
    
    private var message: String
    public init(message: String = NSLocalizedString("error.handling.required", comment: "This field is required")){
        self.message = message
    }
    
    open func validate(_ value: String) -> Bool {
        return !value.isEmpty
    }
    
    open func errorMessage() -> String {
        return message
    }
}
