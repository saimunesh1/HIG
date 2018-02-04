//
//  MinLengthRule.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import Foundation

public class MinTextLengthRule: FieldRule {
    private var defaultlenth: Int = 4
    
    private var message: String = NSLocalizedString("error.handling.minlength", comment: "")
    public init(){}

    public init(length: Int, message: String = "error.handling.printelabel"){
        self.defaultlenth = length
        self.message = String(format: message, self.defaultlenth)
    }
    
    public func validate(_ value: String) -> Bool {
        return value.count >= defaultlenth
    }
    
    public func errorMessage() -> String {
        return message
    }
}
