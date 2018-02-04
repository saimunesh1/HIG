//
//  MaxTextLengthRule.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class MaxTextLengthRule: FieldRule {
    
    private var defaultlength: Int = 8
    
    private var message: String = NSLocalizedString("error.handling.maxlength", comment: "max length")
    
    public init(){}

    public init(length: Int, message: String = NSLocalizedString("error.handling.printelabel", comment: "")){
        self.defaultlength = length
        self.message = String(format: message, self.defaultlength)
    }
    
    public func validate(_ value: String) -> Bool {
        return value.count <= defaultlength
    }
    
    public func errorMessage() -> String {
        return message
    }
}
