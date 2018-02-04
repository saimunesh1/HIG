//
//  OnOffSegmentControl.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/20/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class OnOffSegmentControl: CustomSegmentControl {

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
            let yes = NSLocalizedString("On", comment: "")
            let no = NSLocalizedString("Off", comment: "")
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
