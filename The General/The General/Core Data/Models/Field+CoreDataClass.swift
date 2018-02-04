//
//  Field+CoreDataClass.swift
//  The General
//
//  Created by Derek Bowen on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import CoreData
import MagicalRecord

@objc(Field)
public class Field: NSManagedObject {
    func getFieldValues() -> [Value]? {
        return validValuesArray ?? []
    }
    
    func filterRows() -> Bool {
        if self.rulesArray?.first?.parentFieldResponseKey != "claim.vehicleCount" {
            return true
        }
        // filter rows based on vehicle count selection
        guard let rule = self.rulesArray?.first,
            let parentFieldResponseKey = rule.parentFieldResponseKey,
            let selectedAccidentType = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: parentFieldResponseKey) else {
                return true
        }
        let results: [ParentValue] = (rule.parentValuesArray?.filter { el in el.value!.code == selectedAccidentType.lowercased() })!
        
        return !results.isEmpty
    }
    
    // get the values based on responseKey
    func filterForLocationSelection(responsKey: String) -> String {
        
        if self.rulesArray?.first?.parentFieldResponseKey != responsKey {
            return ""
        }
        guard let rule = self.rulesArray?.first,
            let parentFieldResponseKey = rule.parentFieldResponseKey,
            let selectedAccidentType = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: parentFieldResponseKey) else {
                return ""
        }
        return selectedAccidentType.lowercased()
    }
    
    var typeEnum: CellType? {
        return CellType(rawValue: self.type ?? "")
    }
    
    /// - Service Response Parsing
    func populate(fromResponse response: FieldResponse, inContext context: NSManagedObjectContext) {
        self.defaultValue = response.defaultValue
        self.label = response.label
        self.onlyDisplay = response.onlyDisplay
        self.order = response.order
		self.placeHolder = response.placeHolder
        self.required = response.required
        self.responseKey = response.responseKey
        self.showSubFieldsInNewPage = response.showSubFieldsInNewPage
        self.showValuesInNewPage = response.showValuesInNewPage
        self.title = response.title
        self.type = response.type?.rawValue
        
        if let rules = response.rules {
            for rule in rules {
                let moRule = Rule.mr_createEntity(in: context)!
                moRule.populate(fromResponse: rule, inContext: context)
                self.addToRules(moRule)
            }
        }
        
        if let subFields = response.subFields {
            for subField in subFields {
                let moSubField = Field.mr_createEntity(in: context)!
                moSubField.populate(fromResponse: subField, inContext: context)
                self.addToSubFields(moSubField)
            }
        }
        
        if let validations = response.validations {
            for validation in validations {
                let moValidation = Value.mr_createEntity(in: context)!
                moValidation.value = validation
                self.addToValidations(moValidation)
            }
        }
        
        if let validValues = response.validValues {
            for validValue in validValues {
                let moValidValue = Value.mr_createEntity(in: context)!
                moValidValue.populate(fromResponse: validValue, inContext: context)
                self.addToValidValues(moValidValue)
            }
        }
    }
    
    /// - Relationships
    var rulesArray: [Rule]? {
        return self.rules?.array as? [Rule]
    }
    
    var subFieldsArray: [Field]? {
        return self.subFields?.array as? [Field]
    }
    
    var validationsArray: [Value]? {
        return self.validations?.array as? [Value]
    }
    
    var validValuesArray: [Value]? {
        return self.validValues?.array as? [Value]
    }
}
