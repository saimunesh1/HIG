//
//  ExactLengthRule.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ExactLengthRule: FieldRule {
    private var message: String = NSLocalizedString("error.handling.exactlength", comment: "exact length")
    private var length: Int

    public init(length: Int, message: String = NSLocalizedString("error.handling.printelabel", comment: "")){
        self.length = length
        self.message = String(format: message, self.length)
    }
    
    public func validate(_ value: String) -> Bool {
        return value.count == length
    }
    
    public func errorMessage() -> String {
        return message
    }
}
