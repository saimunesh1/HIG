//
//  DisappearingLabel.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 1/10/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

// Dissappears when text start to truncate
//
class DisappearingLabel: UILabel {
    
    var mayBeTruncating: Bool {
        
        guard let labelText = text else {
            return false
        }
        
        // This will get the estimated size of the text within the label, passing in current frame width as limiter, no height limiter
        let labelTextSize = (labelText as NSString).boundingRect(with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size
        
        // If the estimated size given that width is current frame width, is taller than current frame height, then it's truncated
        return labelTextSize.height > bounds.size.height
    }
    
    override func layoutSubviews() {
        self.isHidden = mayBeTruncating
    }
}
