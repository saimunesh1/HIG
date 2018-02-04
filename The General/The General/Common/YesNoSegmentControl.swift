//
//  YesNoSegmentControl.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 11/27/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class YesNoSegmentControl: CustomSegmentControl {
    
    var value: Bool {
        get {
            return self.selectedIndex == 0
        }
        
        set {
            self.selectedIndex = newValue ? 0 : 1
        }
    }
    
    override var items: [String] {
        get {
            let yes = NSLocalizedString("Yes", comment: "")
            let no = NSLocalizedString("No", comment: "")
            return [yes, no]
        }
        set {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectedIndex = 1
    }

}
