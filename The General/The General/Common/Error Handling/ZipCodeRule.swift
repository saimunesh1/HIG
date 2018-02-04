//
//  ZipCodeRule.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ZipCodeRule: RegexRule {

    public convenience init(message: String =  NSLocalizedString("Enter a valid 5 digit zipcode", comment: "")){
        self.init(regex: "\\d{5}", message: message)
    }
}

public class CharacterSetRule: FieldRule {
    private let characterSet: CharacterSet
    private var message: String

    public init(characterSet: CharacterSet, message: String = "Enter valid alpha") {
        self.characterSet = characterSet
        self.message = message
    }

    public func validate(_ value: String) -> Bool {
        for uni in value.unicodeScalars {
            guard let uniVal = UnicodeScalar(uni.value), characterSet.contains(uniVal) else {
                return false
            }
        }
        return true
    }
    
    public func errorMessage() -> String {
        return message
    }
}
