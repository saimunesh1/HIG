//
//  PolicyNumberRule.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 11/27/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PolicyNumberRule: RegexRule {
    public init() {
        super.init(regex: "^([a-zA-Z0-9]{2,4})?[0-9]{7}$", message: "Invalid Policy Number")
    }
}
