//
//  OrRule.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 11/27/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class OrRule: FieldRule {
    private var message: String = "Invalid value"
    private var rules: [FieldRule]
    
    public init(_ rules: [FieldRule], message: String){
        self.rules = rules
        self.message = message
    }
    
    func validate(_ value: String) -> Bool {
        var valid: Bool = false
        
        for rule in self.rules {
            valid = valid || rule.validate(value)
        }

        return valid
    }
    
    func errorMessage() -> String {
        return message
    }

}
