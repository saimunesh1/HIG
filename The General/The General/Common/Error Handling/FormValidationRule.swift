//
//  FormValidationRule.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public class FormValidationRule {
    public var field: FieldToValidate
    public var errorLabel: UILabel?
    public var rules: [FieldRule] = []

    public init(field: FieldToValidate, rules: [FieldRule], errorLabel: UILabel?){
        self.field = field
        self.errorLabel = errorLabel
        self.rules = rules
    }
    
    public func validateField() -> ValidationErrorMessage? {
        return rules.filter{
            return !$0.validate(field.validationText)
            }.map{ rule -> ValidationErrorMessage in return ValidationErrorMessage(field: self.field, errorLabel: self.errorLabel, error: rule.errorMessage()) }.first
    }
}


public protocol FieldRule {
    
    func validate(_ value: String) -> Bool
    func errorMessage() -> String
}

open class RegexRule: FieldRule {
    private var regEx: String = "^(?=.*?[A-Z]).{8,}$"
    private var message: String

    public init(regex: String, message: String = "Invalid Regular Expression"){
        self.regEx = regex
        self.message = message
    }
    
    open func validate(_ value: String) -> Bool {
        let test = NSPredicate(format: "SELF MATCHES %@", self.regEx)
        return test.evaluate(with: value)
    }
    
    open func errorMessage() -> String {
        return message
    }
}
