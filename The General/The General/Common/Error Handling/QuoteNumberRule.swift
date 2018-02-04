//
//  QuoteNumberRule.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/22/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class QuoteNumberRule: RegexRule {
	public init() {
		super.init(regex: "^[0-9]{7,8}$", message: "Invalid Quote Number")
	}
}
