//
//  EmailRule.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 11/27/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class EmailRule: RegexRule {
    public init() {
        super.init(regex: "^[^@]+@[^@]+\\.[^\\.]+$", message: "Invalid Email")
    }
}
