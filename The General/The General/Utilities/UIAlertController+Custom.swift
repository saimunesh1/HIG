//
//  UIAlertController+Custom.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/21/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    func changeTitleFont(fontStyle: UIFont?) {
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: self.title!, attributes: [NSAttributedStringKey.font:fontStyle ?? UIFont.systemFont(ofSize: 14)])
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.tgTextFontColor, range: NSRange(location: 0, length: (self.title?.count)!))
        self.setValue(myMutableString, forKey: "attributedTitle")
    }
    
}
