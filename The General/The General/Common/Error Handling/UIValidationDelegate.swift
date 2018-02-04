//
//  UIValidationDelegate.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import Foundation

public protocol UIValidationDelegate {
    func validationSuccessful()
    func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)])
}
