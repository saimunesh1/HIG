//
//  ValidationErrorMessage.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public class ValidationErrorMessage: NSObject {

    public let field: FieldToValidate
    public var errorLabel: UILabel?
    public let errorMessage: String
    
    public init(field: FieldToValidate, errorLabel: UILabel?, error: String){
        self.field = field
        self.errorLabel = errorLabel
        self.errorMessage = error
    }

}
