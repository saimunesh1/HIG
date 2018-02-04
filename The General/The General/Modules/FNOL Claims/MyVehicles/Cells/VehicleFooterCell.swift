//
//  VehicleFooterCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/29/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class VehicleFooterCell: UITableViewCell {
    
    var delegate: FooterDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: Selector(("handleTap:")))
        tap.delegate = self
        contentView.addGestureRecognizer(tap)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        
    }
    
}
