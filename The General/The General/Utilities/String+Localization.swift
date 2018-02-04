//
//  String+Localization.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

//==============================================================================
// MARK: - Localization
//==============================================================================

extension String {
    
    mutating func insertString(string: String, replacingTag tagToReplace: String, atIndex index: Int? = 0) {
        
        var numberIndex = 0
        var startPoint = self.startIndex
        
        func search() {
            if let numberRange = self.range(of: tagToReplace, options: .caseInsensitive, range: startPoint..<self.endIndex, locale: nil) {
                
                startPoint = numberRange.upperBound
                
                if index == nil || index == numberIndex {
                    self = self.replacingCharacters(in: numberRange, with: string)
                    startPoint = self.startIndex
                }
                
                numberIndex += 1
                
                search()
            }
        }
        
        search()
    }
}
