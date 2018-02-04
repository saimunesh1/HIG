//
//  String+Formatting.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

extension String {
    
    func caseInsensitiveContains(_ stringToSearchFor: String) -> Bool {
        
        let lowercaseSelf = self.lowercased()
        let lowercaseSearchTerm = stringToSearchFor.lowercased()
        
        return lowercaseSelf.contains(lowercaseSearchTerm)
    }
	
	func addLinkFormattingTo(substring: NSString) -> NSAttributedString? {
		let rangeForLink: NSRange = (self as NSString).range(of: substring as String)
		let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: self)
		attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.tgGreen, range: rangeForLink)
		attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.link, range: rangeForLink)
		return attributedString
	}
    
}
