//
//  FormErrorValidator.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import Foundation

public class FormErrorValidator {

    public var validations = FieldValidatorDictionary<FormValidationRule>()
    public var errors = FieldValidatorDictionary<ValidationErrorMessage>()
    private var fields = FieldValidatorDictionary<Validatable>()
    private var successStyleTransform: ((_ validationRule: FormValidationRule)->Void)?
    private var errorStyleTransform: ((_ validationError: ValidationErrorMessage)->Void)?
    public init(){
        self.styleTransformers(success: defaultSuccessTransformer, error: defaultErrorTransformer)

    }

    private func defaultSuccessTransformer(validationRule: FormValidationRule) {
        validationRule.errorLabel?.isHidden = true
        validationRule.errorLabel?.text = ""
    }

    private func defaultErrorTransformer(validationError: ValidationErrorMessage) {
        validationError.errorLabel?.isHidden = false
        validationError.errorLabel?.text = validationError.errorMessage
    }

    private func validateAllFields() {
        
        errors = FieldValidatorDictionary<ValidationErrorMessage>()
        
        for (_, rule) in validations {
            if let error = rule.validateField() {
                errors[rule.field] = error
                if let transform = self.errorStyleTransform {
                    transform(error)
                }
            } else {
                
                if let transform = self.successStyleTransform {
                    transform(rule)
                }
            }
        }
    }
    
    public func validateField(_ field: FieldToValidate, callback: (_ error: ValidationErrorMessage?) -> Void) {
        if let fieldRule = validations[field] {
            if let error = fieldRule.validateField() {
                errors[field] = error
                if let transform = self.errorStyleTransform {
                    transform(error)
                }
                callback(error)
            } else {
                if let transform = self.successStyleTransform {
                    transform(fieldRule)
                }
                callback(nil)
            }
        } else {
            callback(nil)
        }
    }
    
    public func styleTransformers(success: ((_ validationRule: FormValidationRule) -> Void)?, error: ((_ validationError: ValidationErrorMessage)->Void)?) {
        self.successStyleTransform = success
        self.errorStyleTransform = error
    }
    
    public func registerField(_ field: FieldToValidate, errorLabel: UILabel? = nil, rules: [FieldRule]) {
        validations[field] = FormValidationRule(field: field, rules: rules, errorLabel: errorLabel)
        fields[field] = field
    }
    
    public func unregisterField(_ field: FieldToValidate) {
        validations.removeValueForKey(field)
        errors.removeValueForKey(field)
    }
    
    public func validate(_ delegate: UIValidationDelegate) {
        
        self.validateAllFields()
        
        if errors.isEmpty {
            delegate.validationSuccessful()
        } else {
            delegate.validationFailed(errors.map { (fields[$1.field]!, $1) })
        }
        
    }
    
    public func validate(_ callback: (_ errors: [(Validatable, ValidationErrorMessage)]) -> Void) -> Void {
        
        self.validateAllFields()
        
        callback(errors.map { (fields[$1.field]!, $1) } )
    }
    
}
