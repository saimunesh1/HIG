//
//  DoneFooterTableViewCell.swift
//  The General
//
//  Created by Michael Moore on 10/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class DoneFooterTableViewCell: UITableViewHeaderFooterView {
    
    var delegate: DamageDetailsFooterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBAction func touchOnDone(_ sender: Any) {
        
        delegate?.touchOnDone()
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
