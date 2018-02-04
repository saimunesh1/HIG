//
//  ValidatableObject.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import Foundation

public typealias FieldToValidate = AnyObject & Validatable

public protocol Validatable {
    var validationText: String {
        get
    }
}

extension UITextField: Validatable {
    public var validationText: String {
        return text ?? ""
    }
}

extension UILabel: Validatable {
	public var validationText: String {
		return text ?? ""
	}
}
